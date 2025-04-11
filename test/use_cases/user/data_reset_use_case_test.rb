require "test_helper"

class User::DataResetUseCaseTest < ActiveSupport::TestCase
  setup do
    @password = "Password1!"
    @user = User.create!(
      email_address: "data_reset_test@example.com",
      password: @password,
      password_confirmation: @password,
      nickname: "데이터리셋테스트",
      is_email_verified: true,
      role_id: 1
    )

    # OTP 생성 및 설정
    @otp = "123456"
    @user.update_otp(@otp)

    # 테스트 데이터 생성
    # 각 모델에 맞게 테스트 데이터 생성 로직 추가
    create_test_data_for_user(@user)
  end

  test "OTP 형식이 잘못된 경우 실패한다" do
    result = User::DataResetUseCase.new(@user, { otp: "abc" }).call

    assert result.failure?
    assert_equal "OTP는 6자리 숫자여야 합니다.", result.error_message
  end

  test "사용자가 없을 경우 실패한다" do
    result = User::DataResetUseCase.new(nil, { otp: @otp }).call

    assert result.failure?
    assert_equal "로그인이 필요합니다.", result.error_message
  end

  test "OTP가 일치하지 않을 경우 실패한다" do
    result = User::DataResetUseCase.new(@user, { otp: "654321" }).call

    assert result.failure?
    assert_equal "OTP가 유효하지 않습니다.", result.error_message
  end

  test "모든 조건이 충족되면 사용자 데이터가 초기화된다" do
    result = User::DataResetUseCase.new(@user, { otp: @otp }).call

    assert result.success?
    assert_equal "데이터가 초기화되었습니다.", result.data[:message]

    # 데이터가 실제로 초기화되었는지 확인
    @user.reload
    assert_nil @user.otp
    assert_nil @user.otp_expiry_date
    assert_equal 0, @user.posts.count
    assert_equal 0, @user.favorites.count
    assert_equal 0, @user.favorite_categories.count
    assert_equal 0, @user.collections.where(type: "DEFAULT").count
  end

  private

  def create_test_data_for_user(user)
    # 테스트에 필요한 데이터 생성
    # 예: 게시물, 즐겨찾기, 카테고리 등
    # 실제 모델에 맞게 구현 필요

    # 예시:
    # post = Post.create!(user: user, title: "Test Post")
    # collection = Collection.create!(user: user, title: "Test Collection", type: "DEFAULT")
    # favorite = Favorite.create!(user: user, target_id: post.id, target_type: "Post")
    # favorite_category = FavoriteCategory.create!(user: user, name: "Test Category")
  end
end
