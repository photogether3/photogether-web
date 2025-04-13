# test/services/post/index_test.rb
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

  test "컬렉션의 게시물 목록을 가져온다" do
    result = Post::Index.new(@user.id, { collectionId: @collection.id }).call
    puts result.inspect
    assert result.success?
    assert_equal 3, result.data[:total_item_count]
    assert_equal 3, result.data[:items].count
  end

  test "페이지네이션이 제대로 적용된다" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      page: 1,
      perPage: 2
    }).call

    puts result.inspect

    assert result.success?
    assert_equal 3, result.data[:total_item_count]  # 전체 게시물 수
    assert_equal 2, result.data[:items].count  # 현재 페이지의 게시물 수
    assert_equal 2, result.data[:per_page]     # 페이지당 게시물 수
    assert_equal 2, result.data[:total_page_count]  # 전체 페이지 수

    # 두 번째 페이지 테스트
    result2 = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      page: 2,
      perPage: 2
    }).call

    assert result2.success?
    assert_equal 1, result2.data[:items].count  # 두 번째 페이지의 게시물 수
    assert_equal 2, result2.data[:current_page]         # 현재 페이지
  end

  test "생성일 기준으로 정렬된다 (최신순)" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortBy: "created_at",
      sortOrder: "desc"
    }).call

    assert result.success?
    items = result.data[:items]

    # 생성일 역순 (최신순) 확인
    assert_equal @post3.id, items[0][:id]
    assert_equal @post2.id, items[1][:id]
    assert_equal @post1.id, items[2][:id]
  end

  test "생성일 기준으로 오름차순 정렬된다 (오래된순)" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortBy: "created_at",
      sortOrder: "asc"
    }).call

    assert result.success?
    items = result.data[:items]

    # 생성일 순서대로 (오래된순) 확인
    assert_equal @post1.id, items[0][:id]
    assert_equal @post2.id, items[1][:id]
    assert_equal @post3.id, items[2][:id]
  end

  test "제목 기준으로 정렬된다" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortBy: "title",
      sortOrder: "asc"
    }).call

    assert result.success?
    items = result.data[:items]

    # 제목 오름차순 확인
    assert_equal "A 게시물", items[0][:title]
    assert_equal "M 게시물", items[1][:title]
    assert_equal "Z 게시물", items[2][:title]

    # 제목 내림차순 테스트
    result2 = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortBy: "title",
      sortOrder: "desc"
    }).call

    items2 = result2.data[:items]
    assert_equal "Z 게시물", items2[0][:title]
    assert_equal "M 게시물", items2[1][:title]
    assert_equal "A 게시물", items2[2][:title]
  end

  test "다른 컬렉션의 게시물은 가져오지 않는다" do
    result = Post::Index.new(@user.id, { collectionId: @collection.id }).call

    assert result.success?
    post_ids = result.data[:items].map { |item| item[:id] }

    assert_not_includes post_ids, @other_collection_post.id
  end

  test "다른 사용자의 게시물은 가져오지 않는다" do
    result = Post::Index.new(@user.id, { collectionId: @collection.id }).call

    assert result.success?
    post_ids = result.data[:items].map { |item| item[:id] }

    assert_not_includes post_ids, @other_user_post.id
  end

  test "존재하지 않는 컬렉션 ID로 호출 시 실패한다" do
    result = Post::Index.new(@user.id, { collectionId: 9999 }).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 컬렉션 ID로 호출 시 실패한다" do
    result = Post::Index.new(@user.id, { collectionId: @other_user_collection.id }).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "유효하지 않은 정렬 필드는 기본값(created_at)으로 대체된다" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortBy: "invalid_field"
    }).call

    assert result.success?
    items = result.data[:items]

    # 기본 정렬(생성일 내림차순) 확인
    assert_equal @post3.id, items[0][:id]
    assert_equal @post2.id, items[1][:id]
    assert_equal @post1.id, items[2][:id]
  end

  test "유효하지 않은 정렬 방향은 기본값(desc)으로 대체된다" do
    result = Post::Index.new(@user.id, {
      collectionId: @collection.id,
      sortOrder: "invalid_order"
    }).call

    assert result.success?
    items = result.data[:items]

    # 기본 정렬 방향(내림차순) 확인
    assert_equal @post3.id, items[0][:id]
    assert_equal @post2.id, items[1][:id]
    assert_equal @post1.id, items[2][:id]
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
