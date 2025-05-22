require "test_helper"

class Post::IndexTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "post_index_test@example.com",
      password: "Password1!",
      nickname: "목록테스트사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 생성
    @collection = Collection.create!(
      title: "테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 다른 컬렉션 생성
    @other_collection = Collection.create!(
      title: "다른 테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_index_test@example.com",
      password: "Password1!",
      nickname: "다른목록테스트사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 다른 사용자의 컬렉션 생성
    @other_user_collection = Collection.create!(
      title: "다른 사용자의 컬렉션",
      category_id: @category.id,
      user_id: @other_user.id,
      type: "DEFAULT"
    )

    # 테스트 게시물 생성 (정렬 테스트를 위해 시간 간격을 둠)
    @post1 = create_test_post("Z 게시물", "Z 내용", 3.days.ago)
    @post2 = create_test_post("A 게시물", "A 내용", 2.days.ago)
    @post3 = create_test_post("M 게시물", "M 내용", 1.day.ago)

    # 다른 컬렉션에 게시물 생성
    @other_collection_post = Post.create!(
      title: "다른 컬렉션 게시물",
      content: "다른 컬렉션 내용",
      user_id: @user.id,
      collection_id: @other_collection.id,
      created_at: Time.current
    )

    # 다른 사용자의 게시물 생성
    @other_user_post = Post.create!(
      title: "다른 사용자 게시물",
      content: "다른 사용자 내용",
      user_id: @other_user.id,
      collection_id: @other_user_collection.id,
      created_at: Time.current
    )
  end

  test "키워드로 게시물을 검색한다 (제목 기준)" do
    # 키워드가 제목에 포함된 게시물 검색
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "A 게시물"
    }).call

    assert result.success?
    assert_equal 1, result.data[:total_item_count]
    assert_equal 1, result.data[:items].count
    assert_equal @post2.id, result.data[:items][0][:id]
    assert_equal "A 게시물", result.data[:items][0][:title]
  end

  test "키워드로 게시물을 검색한다 (내용 기준)" do
    # 키워드가 내용에 포함된 게시물 검색
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "M 내용"
    }).call

    assert result.success?
    assert_equal 1, result.data[:total_item_count]
    assert_equal 1, result.data[:items].count
    assert_equal @post3.id, result.data[:items][0][:id]
    assert_equal "M 게시물", result.data[:items][0][:title]
  end

  test "키워드로 여러 게시물을 검색한다 (부분 매칭)" do
    # 여러 게시물에 걸쳐 부분 매칭되는 키워드 검색
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "게시물"
    }).call

    assert result.success?
    assert_equal 3, result.data[:total_item_count]
    assert_equal 3, result.data[:items].count

    # 결과에 모든 게시물이 포함되어 있는지 확인
    post_ids = result.data[:items].map { |item| item[:id] }
    assert_includes post_ids, @post1.id
    assert_includes post_ids, @post2.id
    assert_includes post_ids, @post3.id
  end

  test "검색 결과가 없는 경우 빈 목록을 반환한다" do
    # 존재하지 않는 키워드로 검색
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "존재하지않는키워드XYZ"
    }).call

    assert result.success?
    assert_equal 0, result.data[:total_item_count]
    assert_equal 0, result.data[:items].count
    assert_empty result.data[:items]
  end

  test "키워드 검색과 정렬이 함께 적용된다" do
    # 추가 테스트 데이터 생성 (같은 키워드를 포함하는 게시물들)
    another_post1 = create_test_post("테스트 AAA", "키워드 포함", 5.days.ago)
    another_post2 = create_test_post("테스트 CCC", "키워드 포함", 4.days.ago)

    # 키워드로 검색하면서 제목 기준 내림차순 정렬
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "테스트",
      sortBy: "title",
      sortOrder: "desc"
    }).call

    assert result.success?
    assert_equal 2, result.data[:total_item_count]
    assert_equal 2, result.data[:items].count

    # 제목 내림차순 정렬 확인
    assert_equal "테스트 CCC", result.data[:items][0][:title]
    assert_equal "테스트 AAA", result.data[:items][1][:title]
  end

  test "키워드 검색과 페이지네이션이 함께 적용된다" do
    # 추가 테스트 데이터 생성 (같은 키워드를 포함하는 게시물들)
    5.times do |i|
      create_test_post("공통 키워드 #{i+1}", "페이지네이션 테스트", (i+1).days.ago)
    end

    # 첫 번째 페이지 (2개 항목)
    result1 = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "공통 키워드",
      page: 1,
      perPage: 2
    }).call

    assert result1.success?
    assert_equal 5, result1.data[:total_item_count]  # 전체 검색 결과 수
    assert_equal 2, result1.data[:items].count       # 현재 페이지 항목 수
    assert_equal 1, result1.data[:current_page]      # 현재 페이지
    assert_equal 3, result1.data[:total_page_count]  # 전체 페이지 수

    # 두 번째 페이지 (2개 항목)
    result2 = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "공통 키워드",
      page: 2,
      perPage: 2
    }).call

    assert result2.success?
    assert_equal 5, result2.data[:total_item_count]  # 전체 검색 결과 수
    assert_equal 2, result2.data[:items].count       # 현재 페이지 항목 수
    assert_equal 2, result2.data[:current_page]      # 현재 페이지

    # 세 번째 페이지 (1개 항목)
    result3 = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      keyword: "공통 키워드",
      page: 3,
      perPage: 2
    }).call

    assert result3.success?
    assert_equal 5, result3.data[:total_item_count]  # 전체 검색 결과 수
    assert_equal 1, result3.data[:items].count       # 현재 페이지 항목 수
    assert_equal 3, result3.data[:current_page]      # 현재 페이지
  end

  private

  def create_test_post(title, content, created_at)
    post = Post.create!(
      title: title,
      content: content,
      user_id: @user.id,
      collection_id: @collection.id,
      created_at: created_at,
      updated_at: created_at
    )

    # 메타데이터 추가
    post.post_metadata.create!(
      content: "#{title}의 메타데이터",
      is_public: true,
      has_link: false
    )

    post
  end
end
