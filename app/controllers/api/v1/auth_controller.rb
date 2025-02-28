class Api::V1::AuthController < Api::ApplicationApiController
  def login
    # 예제 토큰 값 생성 (실제 구현에서는 JWT 토큰 생성 로직을 추가해야 함)
    access_token = "example_access_token"
    refresh_token = "example_refresh_token"
    expires_in = 3600 # 1시간 (초 단위)

    render_auth_response(access_token, refresh_token, expires_in)
  end

  def register
    User.register(params)
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    email = params[:email]
    raise ArgumentError, "Email missing" if email.blank?
    unless email.match?(User::VALID_EMAIL_REGEX)
      raise ArgumentError, "Invalid email format"
    end
    User.generateOtp(params)
    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
  end

  def refresh
  end

  def logout
  end
end
