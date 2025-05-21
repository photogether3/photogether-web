# test/use_cases/auth/login_processor_test.rb
require "test_helper"

class Auth::LoginTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "Password1!",
      is_email_verified: true,
      nickname: "TestUser",
      role_id: 1
    )
  end

  test "로그인 성공 시 토큰을 반환한다" do
    result = Auth::Login.new(email: @user.email_address, password: "Password1!").call

    assert result.success?
    assert result.data[:access_token].present?
    assert result.data[:refresh_token].present?
    assert result.data[:expires_in].present?
  end

  test "이메일이 유효하지 않으면 실패한다" do
    result = Auth::Login.new(email: "invalid_email", password: "Password1!").call

    assert result.failure?
    assert_equal "유효한 이메일을 입력해 주세요.", result.error_message
    assert_equal "INVALID_EMAIL", result.error_code
  end

  test "등록되지 않은 이메일이면 실패한다" do
    result = Auth::Login.new(email: "nonexist@example.com", password: "Password1!").call

    assert result.failure?
    assert_equal "아이디 또는 비밀번호를 찾을 수 없습니다.", result.error_message
    assert_equal "INVALID_CREDENTIALS", result.error_code
  end

  test "이메일 인증이 안 된 경우 실패한다" do
    @user.update!(is_email_verified: false)

    result = Auth::Login.new(email: @user.email_address, password: "Password1!").call

    assert result.failure?
    assert_equal "이메일 인증을 완료해주세요.", result.error_message
    assert_equal "EMAIL_NOT_VERIFIED", result.error_code
  end

  test "비밀번호가 없으면 실패한다" do
    result = Auth::Login.new(email: @user.email_address, password: "").call

    assert result.failure?
    assert_equal "비밀번호를 입력해 주세요.", result.error_message
    assert_equal "MISSING_PASSWORD", result.error_code
  end

  test "비밀번호가 틀리면 실패한다" do
    result = Auth::Login.new(email: @user.email_address, password: "WrongPassword!").call

    assert result.failure?
    assert_equal "아이디 또는 비밀번호를 찾을 수 없습니다.", result.error_message
    assert_equal "INVALID_CREDENTIALS", result.error_code
  end
end