class Api::V1::AuthController < Api::ApplicationApiController
  before_action :ensure_valid_email, only: [ :login, :register, :generate_otp, :verify_otp ]
  before_action :ensure_valid_password, only: [ :login, :register ]

  def login
    tokens = User.login_usecase(params[:email], params[:password])
    render json: tokens, status: :ok
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
end
