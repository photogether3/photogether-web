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
    refresh_token = request.headers["x-refresh-token"]
    raise CustomError, "리프레시 토큰이 없습니다." if refresh_token.blank?

    refresh_token_model = RefreshToken.find_by(refresh_token: refresh_token)

    err_msg = "리프레시 토큰이 유효하지 않습니다."
    raise CustomError, err_msg unless refresh_token_model

    if refresh_token_model.expiry_date < Time.current
      raise CustomError, err_msg
    end

    user = refresh_token_model.user
    tokens = JwtUtil.generate_tokens(user.id)
    RefreshToken.create_or_update_usecase(user.id, tokens[:refresh_token])

    render json: tokens, status: :ok
  end


  def logout
  end
end
