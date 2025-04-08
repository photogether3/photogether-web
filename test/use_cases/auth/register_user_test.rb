# test/use_cases/auth/register_user_test.rb
require "test_helper"

class Auth::RegisterUserTest < ActiveSupport::TestCase
  test "회원가입 성공 시 유저를 반환한다" do
    params = {
      email: "new_user@example.com",
      password: "Password1!"
    }

    result = Auth::RegisterUser.new(params).call

    assert result.success?
    user = result.data
    assert user.is_a?(User)
    assert_equal "new_user@example.com", user.email_address
    assert user.nickname.present?
    assert_equal 2, user.collections.count

    uncategorized = user.collections.find_by(type: "UNCATEGORIZED")
    trash = user.collections.find_by(type: "TRASH")
    assert uncategorized
    assert trash
  end

  test "이메일 형식이 유효하지 않으면 실패한다" do
    params = {
      email: "invalid_email",
      password: "Password1!"
    }

    result = Auth::RegisterUser.new(params).call

    assert result.failure?
    assert_equal "유효한 이메일을 입력해 주세요.", result.error_message
  end

  test "비밀번호가 없으면 실패한다" do
    params = {
      email: "new_user@example.com",
      password: ""
    }

    result = Auth::RegisterUser.new(params).call

    assert result.failure?
    assert_equal "비밀번호를 입력해 주세요.", result.error_message
  end
end
