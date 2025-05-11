# test/services/collection/index_test.rb
require "test_helper"

class Collection::IndexTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "collection_index_test@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "컬렉션목록테스트",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션들 생성 - 명확한 타임스탬프와 ID 순서 보장
    @collection1 = Collection.create!(
      title: "첫번째 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT",
      created_at: 3.days.ago
    )

    # 다음 컬렉션 생성 전 약간의 지연 추가
    sleep(0.1)

    @collection2 = Collection.create!(
      title: "두번째 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT",
      created_at: 2.days.ago
    )

    # 다음 컬렉션 생성 전 약간의 지연 추가
    sleep(0.1)

    @collection3 = Collection.create!(
      title: "세번째 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT",
      created_at: 1.day.ago
    )

    # 시스템 컬렉션 생성
    @trash_collection = Collection.create!(
      title: "휴지통",
      user_id: @user.id,
      type: "TRASH",
      created_at: 4.days.ago
    )

    @uncategorized_collection = Collection.create!(
      title: "미분류",
      user_id: @user.id,
      type: "UNCATEGORIZED",
      created_at: 5.days.ago
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_user_index@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "다른사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 다른 사용자의 컬렉션
    @other_collection = Collection.create!(
      title: "다른 사용자의 컬렉션",
      category_id: @category.id,
      user_id: @other_user.id,
      type: "DEFAULT"
    )

    # 검색용 컬렉션 추가
    @search_collection = Collection.create!(
      title: "검색어_테스트_컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )
  end

  test "사용자의 모든 컬렉션을 생성일 내림차순으로 가져온다" do
    # 서비스 실행 (기본 정렬: created_at desc)
    result = Collection::Index.new(@user.id).call

    # 결과 확인
    assert result.success?
    assert_equal 6, result.data[:total_item_count] # 일반 3개 + 검색용 1개 + 시스템 2개
    assert_equal 1, result.data[:current_page]

    # 순서 확인 (최신순)
    items = result.data[:items]
    first_five_ids = items.take(5).map { |item| item[:id] }

    # 최신 순으로 정렬되어 있어야 함
    assert_includes first_five_ids, @search_collection.id  # 가장 최근 생성
    assert_includes first_five_ids, @collection3.id        # 1일 전에 생성
    assert_includes first_five_ids, @collection2.id        # 2일 전에 생성
    assert_includes first_five_ids, @collection1.id        # 3일 전에 생성
  end

  test "페이지네이션이 제대로 적용된다" do
    # 페이지네이션 파라미터로 서비스 실행
    result = Collection::Index.new(@user.id, { page: 1, perPage: 3 }).call

    # 결과 확인
    assert result.success?
    assert_equal 6, result.data[:total_item_count]  # 총 6개 아이템
    assert_equal 2, result.data[:total_page_count]  # 페이지당 3개씩이면 총 2페이지
    assert_equal 3, result.data[:items].size        # 첫 페이지에 3개 아이템

    # 두 번째 페이지 확인
    result2 = Collection::Index.new(@user.id, { page: 2, perPage: 3 }).call
    assert_equal 3, result2.data[:items].size      # 두 번째 페이지에 3개 아이템
  end

  test "정렬 순서를 변경할 수 있다" do
    # 생성일 오름차순 정렬 (오래된 순)
    result = Collection::Index.new(@user.id, { sortBy: "created_at", sortOrder: "asc" }).call

    # 결과 확인 - 생성일 순으로 검증
    items = result.data[:items]

    # 오래된 순서로 정렬되었는지 확인
    oldest_collection_ids = [
      @uncategorized_collection.id,  # 5일 전
      @trash_collection.id,          # 4일 전
      @collection1.id                # 3일 전
    ]

    first_three_ids = items.take(3).map { |item| item[:id] }
    oldest_collection_ids.each do |id|
      assert_includes first_three_ids, id
    end
  end

  test "다른 사용자의 컬렉션은 포함되지 않는다" do
    # 서비스 실행
    result = Collection::Index.new(@user.id).call

    # 결과 확인
    items = result.data[:items]
    item_ids = items.map { |item| item[:id] }

    # 다른 사용자의 컬렉션이 포함되지 않음을 확인
    assert_not_includes item_ids, @other_collection.id
  end

  test "키워드로 컬렉션을 필터링할 수 있다" do
    # 키워드로 검색
    result = Collection::Index.new(@user.id, { keyword: "검색어" }).call

    # 결과 확인
    assert result.success?

    # 키워드가 포함된 컬렉션만 필터링되어야 함
    item_ids = result.data[:items].map { |item| item[:id] }
    assert_includes item_ids, @search_collection.id

    # 키워드가 없는 일반 컬렉션은 포함되지 않아야 함
    assert_not_includes item_ids, @collection1.id
    assert_not_includes item_ids, @collection2.id
    assert_not_includes item_ids, @collection3.id
  end

  test "키워드 검색 시 시스템 컬렉션은 항상 포함된다" do
    # 키워드로 검색
    result = Collection::Index.new(@user.id, { keyword: "검색어" }).call

    # 결과 확인
    assert result.success?

    # 시스템 컬렉션은 키워드와 상관없이 항상 포함되어야 함
    item_ids = result.data[:items].map { |item| item[:id] }
    assert_includes item_ids, @trash_collection.id
    assert_includes item_ids, @uncategorized_collection.id

    # 키워드가 포함된 컬렉션도 포함되어야 함
    assert_includes item_ids, @search_collection.id

    # 키워드가 없는 일반 컬렉션은 포함되지 않아야 함
    assert_not_includes item_ids, @collection1.id
    assert_not_includes item_ids, @collection2.id
    assert_not_includes item_ids, @collection3.id
  end

  test "일치하는 키워드가 없을 때도 시스템 컬렉션만 반환된다" do
    # 존재하지 않는 키워드로 검색
    result = Collection::Index.new(@user.id, { keyword: "존재하지않는키워드" }).call

    # 결과 확인
    assert result.success?

    # 시스템 컬렉션만 포함되고 다른 컬렉션은 모두 제외되어야 함
    item_ids = result.data[:items].map { |item| item[:id] }
    assert_includes item_ids, @trash_collection.id
    assert_includes item_ids, @uncategorized_collection.id

    # 일반 컬렉션은 모두 포함되지 않아야 함
    assert_not_includes item_ids, @collection1.id
    assert_not_includes item_ids, @collection2.id
    assert_not_includes item_ids, @collection3.id
    assert_not_includes item_ids, @search_collection.id

    # 총 아이템 수는 시스템 컬렉션 2개여야 함
    assert_equal 2, result.data[:total_item_count]
  end

  test "카테고리 ID로 컬렉션을 필터링할 수 있다" do
    # 추가 카테고리 생성
    second_category = Category.create!(name: "두번째 카테고리")
    
    # 새 카테고리에 속한 컬렉션 생성
    collection_in_second_category = Collection.create!(
      title: "다른 카테고리 컬렉션",
      category_id: second_category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 카테고리 ID로 필터링
    result = Collection::Index.new(@user.id, { categoryId: second_category.id }).call

    # 결과 확인
    assert result.success?
    
    # 지정한 카테고리에 속한 컬렉션만 포함되어야 함
    item_ids = result.data[:items].map { |item| item[:id] }
    assert_includes item_ids, collection_in_second_category.id
    
    # 다른 카테고리의 컬렉션은 포함되지 않아야 함
    assert_not_includes item_ids, @collection1.id
    assert_not_includes item_ids, @collection2.id
    assert_not_includes item_ids, @collection3.id
    
    # 시스템 컬렉션은 카테고리가 없으므로 포함되지 않아야 함
    assert_not_includes item_ids, @trash_collection.id
    assert_not_includes item_ids, @uncategorized_collection.id
    
    # 총 아이템 수는 필터링된 컬렉션 1개여야 함
    assert_equal 1, result.data[:total_item_count]
  end
end
