class Api::V1::AuthController < Api::ApplicationApiController
  before_action :ensure_valid_email, only: [ :register, :generate_otp, :verify_otp ]

  def login
    # 예제 토큰 값 생성 (실제 구현에서는 JWT 토큰 생성 로직을 추가해야 함)
    access_token = "example_access_token"
    refresh_token = "example_refresh_token"
    expires_in = 3600 # 1시간 (초 단위)

    render_auth_response(access_token, refresh_token, expires_in)
  end

  def register
    User.register_usecase(params[:email], params[:password])
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    User.generate_otp_usecase(params[:email])
    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    tokens = User.verify_otp_usecase(params[:email], params[:otp])
    render json: tokens, status: :created
  end

  def refresh
  end

  def logout
  end

  private

  def ensure_valid_email
    email = params[:email]
    raise ArgumentError, "Email missing" if email.blank?
    unless email.match?(User::VALID_EMAIL_REGEX)
      raise ArgumentError, "Invalid email format"
    end
  end
end
