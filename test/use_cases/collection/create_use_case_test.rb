# test/use_cases/collection/create_use_case_test.rb
require "test_helper"

class Collection::CreateUseCaseTest < ActiveSupport::TestCase
  setup do
    # 테스트 유저 생성
    @user = User.create!(
      email_address: "collection_creator@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "컬렉션생성자",
      role_id: 1,
      is_email_verified: true
    )

    # 테스트용 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")
  end

  test "유효한 파라미터로 컬렉션을 성공적으로 생성한다" do
    params = {
      categoryId: @category.id,
      title: "새 컬렉션"
    }

    result = Collection::CreateUseCase.new(@user.id, params).call

    assert result.success?

    # 컬렉션이 실제로 생성됐는지 확인
    collection = Collection.last
    assert_equal "새 컬렉션", collection.title
    assert_equal @category.id, collection.category_id
    assert_equal @user.id, collection.user_id
    assert_equal "DEFAULT", collection.type
  end

  test "존재하지 않는 카테고리 ID로 컬렉션 생성을 시도하면 실패한다" do
    params = {
      categoryId: 9999, # 존재하지 않는 카테고리 ID
      title: "새 컬렉션"
    }

    result = Collection::CreateUseCase.new(@user.id, params).call

    assert result.failure?
    assert_equal "카테고리를 찾을 수 없습니다.", result.error_message

    # 컬렉션이 생성되지 않았는지 확인
    initial_count = Collection.count
    assert_equal initial_count, Collection.count
  end

  test "카테고리 ID가 nil이면 실패한다" do
    params = {
      categoryId: nil,
      title: "새 컬렉션"
    }

    result = Collection::CreateUseCase.new(@user.id, params).call

    assert result.failure?
    assert_equal "카테고리를 찾을 수 없습니다.", result.error_message
  end

  test "제목이 없으면 컬렉션을 생성할 수 없다" do
    params = {
      categoryId: @category.id,
      title: nil
    }

    result = Collection::CreateUseCase.new(@user.id, params).call

    assert result.failure?
    assert_equal "제목을 입력해 주세요.", result.error_message

    # 컬렉션이 생성되지 않았는지 확인
    initial_count = Collection.count
    assert_equal initial_count, Collection.count
  end

  test "제목이 빈 문자열이면 컬렉션을 생성할 수 없다" do
    params = {
      categoryId: @category.id,
      title: ""
    }

    result = Collection::CreateUseCase.new(@user.id, params).call

    assert result.failure?
    assert_equal "제목을 입력해 주세요.", result.error_message

    # 컬렉션이 생성되지 않았는지 확인
    initial_count = Collection.count
    assert_equal initial_count, Collection.count
  end

  test "유효하지 않은 사용자 ID로는 컬렉션을 생성할 수 없다" do
    params = {
      categoryId: @category.id,
      title: "새 컬렉션"
    }

    # 존재하지 않는 사용자 ID
    assert_raises(ActiveRecord::RecordInvalid) do
      Collection::CreateUseCase.new(9999, params).call
    end
  end
end
