require "test_helper"

class Collection::ShowTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "collection_show_test@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "컬렉션조회테스트",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 생성
    @collection = Collection.create!(
      title: "조회 테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_user_show@example.com",
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

  test "자신의 컬렉션을 성공적으로 조회한다" do
    # 서비스 실행
    result = Collection::Show.new(@user.id, @collection.id).call

    # 결과 확인
    assert result.success?
    assert_not_nil result.data
    assert_equal @collection.id, result.data[:id]
    assert_equal @collection.title, result.data[:title]
    assert_equal @category.id, result.data[:category][:id]
  end

  test "존재하지 않는 컬렉션 ID로 조회 시 실패한다" do
    # 존재하지 않는 ID로 조회
    non_existent_id = 99999
    result = Collection::Show.new(@user.id, non_existent_id).call

    # 결과 확인
    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 컬렉션은 조회할 수 없다" do
    # 다른 사용자의 컬렉션 조회 시도
    result = Collection::Show.new(@user.id, @other_collection.id).call

    # 결과 확인
    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end
end
