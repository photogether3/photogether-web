require "test_helper"

class User::UpdateOtpPasswordTest < ActiveSupport::TestCase
  setup do
    @password = "Password1!"
    @new_password = "NewPassword2@"
    @user = User.create!(
      email_address: "otp_password_test@example.com",
      password: @password,
      password_confirmation: @password,
      nickname: "OTP비밀번호테스트",
      is_email_verified: true,
      role_id: 1
    )

    # OTP 생성 및 설정
    @otp = "123456"
    @user.update_otp(@otp)
  end

  test "이메일 형식이 잘못된 경우 실패한다" do
    result = User::UpdateOtpPassword.new({
      email: "invalid-email",
      otp: @otp,
      newPassword: @new_password
    }).call

    assert result.failure?
    assert_equal "유효한 이메일을 입력해 주세요.", result.error_message
  end

  test "OTP 형식이 잘못된 경우 실패한다" do
    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: "abc", # 6자리 숫자가 아님
      newPassword: @new_password
    }).call

    assert result.failure?
    assert_equal "OTP는 6자리 숫자여야 합니다.", result.error_message
  end

  test "새 비밀번호가 없을 경우 실패한다" do
    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: @otp,
      newPassword: ""
    }).call

    assert result.failure?
    assert_equal "새 비밀번호를 입력해 주세요.", result.error_message
  end

  test "존재하지 않는 사용자의 경우 실패한다" do
    result = User::UpdateOtpPassword.new({
      email: "nonexistent@example.com",
      otp: @otp,
      newPassword: @new_password
    }).call

    assert result.failure?
    assert_equal "사용자를 찾을 수 없습니다.", result.error_message
  end

  test "OTP가 일치하지 않을 경우 실패한다" do
    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: "654321", # 잘못된 OTP
      newPassword: @new_password
    }).call

    assert result.failure?
    assert_equal "OTP가 유효하지 않습니다.", result.error_message
  end

  test "모든 조건이 충족되면 비밀번호가 성공적으로 업데이트된다" do
    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: @otp,
      newPassword: @new_password
    }).call

    assert result.success?
    assert_equal "비밀번호가 성공적으로 변경되었습니다.", result.data[:message]

    # 비밀번호가 실제로 변경되었는지 확인
    @user.reload
    assert @user.authenticate(@new_password), "새 비밀번호로 인증이 가능해야 함"
    assert_not @user.authenticate(@password), "이전 비밀번호로 인증이 불가능해야 함"

    # OTP가 초기화되었는지 확인
    assert_nil @user.otp, "OTP가 초기화되어야 함"
    assert_nil @user.otp_expiry_date, "OTP 만료일이 초기화되어야 함"
  end

  test "유효하지 않은 비밀번호 형식은 실패한다" do
    invalid_password = "weak"
    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: @otp,
      newPassword: invalid_password
    }).call

    assert result.failure?
  end

  test "만료된 OTP로는 비밀번호를 변경할 수 없다" do
    # OTP 만료 설정 (과거 시간으로 설정)
    @user.update_column(:otp_expiry_date, 1.day.ago)

    result = User::UpdateOtpPassword.new({
      email: @user.email_address,
      otp: @otp,
      newPassword: @new_password
    }).call

    assert result.failure?
    assert_equal "OTP가 유효하지 않습니다.", result.error_message
  end
end
