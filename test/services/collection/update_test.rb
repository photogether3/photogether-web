require "test_helper"

class Collection::UpdateTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "collection_updater@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "컬렉션수정자",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리들 생성
    @category1 = Category.create!(name: "카테고리1")
    @category2 = Category.create!(name: "카테고리2")

    # 테스트 컬렉션 생성
    @collection = Collection.create!(
      title: "원래 제목",
      category_id: @category1.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 다른 사용자의 컬렉션 생성 (접근 권한 테스트용)
    @other_user = User.create!(
      email_address: "other@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "다른사용자",
      is_email_verified: true,
      role_id: 1
    )

    @other_collection = Collection.create!(
      title: "다른 사용자의 컬렉션",
      category_id: @category1.id,
      user_id: @other_user.id,
      type: "DEFAULT"
    )

    # 시스템 컬렉션 생성 (수정 불가능 테스트용)
    @system_collection = Collection.create!(
      title: "시스템 컬렉션",
      category_id: @category1.id,
      user_id: @user.id,
      type: "SYSTEM"
    )
  end

  test "제목과 카테고리를 성공적으로 업데이트한다" do
    params = {
      title: "새 제목",
      categoryId: @category2.id
    }

    result = Collection::Update.new(@user.id, @collection.id, params).call

    assert result.success?

    # DB에서 컬렉션 다시 조회하여 변경 확인
    updated = Collection.find(@collection.id)
    assert_equal "새 제목", updated.title
    assert_equal @category2.id, updated.category_id
  end

  test "존재하지 않는 컬렉션 ID로는 업데이트할 수 없다" do
    params = {
      title: "새 제목",
      categoryId: @category2.id
    }

    result = Collection::Update.new(@user.id, 9999, params).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 컬렉션은 업데이트할 수 없다" do
    params = {
      title: "새 제목",
      categoryId: @category2.id
    }

    result = Collection::Update.new(@user.id, @other_collection.id, params).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "시스템 타입 컬렉션은 업데이트할 수 없다" do
    params = {
      title: "새 제목",
      categoryId: @category2.id
    }

    result = Collection::Update.new(@user.id, @system_collection.id, params).call

    assert result.failure?
    assert_equal "수정할 수 없는 사진첩입니다.", result.error_message
  end

  test "존재하지 않는 카테고리로는 업데이트할 수 없다" do
    params = {
      title: "새 제목",
      categoryId: 9999
    }

    result = Collection::Update.new(@user.id, @collection.id, params).call

    assert result.failure?
    assert_equal "카테고리를 찾을 수 없습니다.", result.error_message
  end

  test "제목이 빈 값이면 업데이트할 수 없다" do
    params = {
      title: "",
      categoryId: @category2.id
    }

    result = Collection::Update.new(@user.id, @collection.id, params).call

    assert result.failure?
    assert_equal "제목을 입력해 주세요.", result.error_message
  end
end
