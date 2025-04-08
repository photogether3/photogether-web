require "test_helper"

class Api::V1::AuthFlowTest < ActionDispatch::IntegrationTest
  setup do
    @email = "flow@example.com"
    @password = "1q2w3e4r5t!@"
  end

  test "회원가입부터 로그인까지의 인증 흐름" do
    # 1. 회원가입
    post "/api/v1/auth/register", params: {
      email: @email,
      password: @password
    }
    assert_response :created

    # 2. OTP 발급
    post "/api/v1/auth/otp/generate", params: {
      email: @email
    }
    assert_response :ok
    user = User.find_by(email_address: @email)
    assert user.present?
    otp_code = user.otp

    # 3. OTP 검증 + 토큰 발급
    post "/api/v1/auth/otp/verify-and-login", params: {
      email: @email,
      otp: otp_code
    }
    assert_response :ok
    result = JSON.parse(response.body)
    access_token = result["accessToken"]
    refresh_token = result["refreshToken"]

    assert access_token.present?, "엑세스토큰이 존재해야 합니다"
    assert refresh_token.present?, "리프레시토큰이 존재해야 합니다"
    assert result["expiresIn"].present?, "만료시간도 반환되어야 합니다"

    # 4. 토큰 재발급
    post "/api/v1/auth/refresh", headers: {
      "x-refresh-token" => refresh_token
    }
    assert_response :ok
    refreshed = JSON.parse(response.body)
    assert refreshed["accessToken"].present?
    assert refreshed["refreshToken"].present?
    assert refreshed["expiresIn"].present?

    # 5. 로그아웃
    delete "/api/v1/auth/logout", headers: {
      "Authorization" => "Bearer #{refreshed["accessToken"]}"
    }
    assert_response :ok
    logout_result = JSON.parse(response.body)
    assert_includes logout_result["message"], "로그아웃"
  end
end
