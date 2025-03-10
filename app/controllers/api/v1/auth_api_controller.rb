class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]
  before_action :ensure_valid_email, only: [ :login, :register, :generate_otp, :verify_otp ]
  before_action :ensure_valid_password, only: [ :login, :register ]
  before_action :get_user_from_email, only: [ :login, :generate_otp, :verify_otp ]

  def login
    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    raise CustomError, err_msg unless @user
    raise CustomError, err_msg if !@user.authenticate(password)
    raise CustomError, "이메일 인증을 완료해주세요." unless @user.is_email_verified

    tokens = JwtUtil.generate_tokens(@user.id)
    RefreshToken.create_or_update_usecase(@user.id, tokens[:refresh_token])

    render json: tokens, status: :ok
  end

  def register
    User.register_usecase(params[:email], params[:password])
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    raise ActiveRecord::RecordNotFound, "User not found" unless @user
    @user.update_otp

    UserMailer.send_otp_email(@user).deliver_now

    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    raise ActiveRecord::RecordNotFound, "User not found" unless @user

    is_valid = @user.verify_otp(params[:otp])
    raise CustomError, "OTP has expired" unless is_valid

    @user.reset_otp

    tokens = JwtUtil.generate_tokens(@user.id)
    RefreshToken.create_or_update_usecase(@user.id, tokens[:refresh_token])

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
    refresh_token_model = @current_user.refresh_token
    refresh_token_model.destroy if refresh_token_model
    render json: { message: "로그아웃 성공" }, status: :ok
  end

  private

  def get_user_from_email
    @user = User.find_by(email_address: params[:email])
  end
end
