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
  end

  test "사용자의 모든 컬렉션을 생성일 내림차순으로 가져온다" do
    # 서비스 실행 (기본 정렬: created_at desc)
    result = Collection::Index.new(@user.id).call

    # 결과 확인
    assert result.success?
    assert_equal 3, result.data[:total_item_count]
    assert_equal 1, result.data[:current_page]

    # 순서 확인 (최신순)
    items = result.data[:items]
    assert_equal @collection3.id, items[0][:id]
    assert_equal @collection2.id, items[1][:id]
    assert_equal @collection1.id, items[2][:id]
  end

  test "페이지네이션이 제대로 적용된다" do
    # 페이지네이션 파라미터로 서비스 실행
    result = Collection::Index.new(@user.id, { page: 1, perPage: 2 }).call

    # 결과 확인
    assert result.success?
    assert_equal 3, result.data[:total_item_count] # 총 아이템 수는 여전히 3개
    assert_equal 2, result.data[:total_page_count] # 페이지당 2개씩이면 총 2페이지
    assert_equal 2, result.data[:items].size # 첫 페이지에 2개 아이템

    # 두 번째 페이지 확인
    result2 = Collection::Index.new(@user.id, { page: 2, perPage: 2 }).call
    assert_equal 1, result2.data[:items].size # 두 번째 페이지에 1개 아이템
  end

  test "정렬 순서를 변경할 수 있다" do
    # 생성일 오름차순 정렬 (오래된 순)
    result = Collection::Index.new(@user.id, { sortBy: "created_at", sortOrder: "asc" }).call

    # 결과 확인 - 생성일 순으로 검증
    items = result.data[:items]

    # 가장 오래된 컬렉션부터 나와야 함
    assert_equal @collection1.id, items[0][:id]  # 3일 전에 생성
    assert_equal @collection2.id, items[1][:id]  # 2일 전에 생성
    assert_equal @collection3.id, items[2][:id]  # 1일 전에 생성
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
end
