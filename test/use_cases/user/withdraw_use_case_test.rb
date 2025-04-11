require "test_helper"

class User::WithdrawUseCaseTest < ActiveSupport::TestCase
  setup do
    @password = "Password1!"
    @user = User.create!(
      email_address: "account_delete_test@example.com",
      password: @password,
      password_confirmation: @password,
      nickname: "계정삭제테스트",
      is_email_verified: true,
      role_id: 1
    )

    # OTP 생성 및 설정
    @otp = "123456"
    @user.update_otp(@otp)
  end

  test "OTP 형식이 잘못된 경우 실패한다" do
    result = User::WithdrawUseCase.new(@user, { otp: "abc" }).call

    assert result.failure?
    assert_equal "OTP는 6자리 숫자여야 합니다.", result.error_message
  end

  test "사용자가 없을 경우 실패한다" do
    result = User::WithdrawUseCase.new(nil, { otp: @otp }).call

    assert result.failure?
    assert_equal "로그인이 필요합니다.", result.error_message
  end

  test "OTP가 일치하지 않을 경우 실패한다" do
    result = User::WithdrawUseCase.new(@user, { otp: "654321" }).call

    assert result.failure?
    assert_equal "OTP가 유효하지 않습니다.", result.error_message
  end

  test "모든 조건이 충족되면 사용자 계정이 삭제된다" do
    user_id = @user.id
    result = User::WithdrawUseCase.new(@user, { otp: @otp }).call

    assert result.success?
    assert_equal "계정이 삭제되었습니다.", result.data[:message]

    # 계정이 실제로 삭제되었는지 확인
    assert_nil User.find_by(id: user_id)
  end
end
