class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    email    = params[:email] ||= ""
    password = params[:password] ||= ""

    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::EMAIL_REGEX)
    raise ArgumentError, "비밀번호를 입력해 주세요." if password.blank?

    user = User.find_by(email_address: email)

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    raise CustomError, err_msg unless user
    raise CustomError, err_msg if !user.authenticate(password)
    raise CustomError, "이메일 인증을 완료해주세요." unless user.is_email_verified

    tokens = JwtUtil.generate_tokens(user.id)
    RefreshToken.create_or_update(user.id, tokens[:refresh_token])
    render json: tokens, status: :ok
  end

  def register
    result = Auth::RegisterUser
      .new(params[:email], params[:password])
      .execute
    render_result(result, success_status: :created)
  end

  def generate_otp
    email = params[:email] ||= ""
    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::EMAIL_REGEX)
    user = User.find_by(email_address: email)
    raise CustomError, "사용자를 찾을 수 없습니다." unless user

    user.update_otp
    UserMailer.send_otp_email(user).deliver_now
    render json: { message: "OTP 발급 성공" }, status: :ok
  end

  def verify_otp
    email = params[:email] ||= ""
    otp   = params[:otp] ||= ""

    validate_otp_params(email, otp)
    find_and_verify_user_otp(email, otp)

    render json: { message: "OTP 검증 성공" }, status: :ok
  end

  def verify_otp_with_generate_token
    email = params[:email] ||= ""
    otp   = params[:otp] ||= ""

    validate_otp_params(email, otp)
    user = find_and_verify_user_otp(email, otp)

    user.reset_otp { |u| u.is_email_verified = true }

    tokens = JwtUtil.generate_tokens(user.id)
    RefreshToken.create_or_update(user.id, tokens[:refresh_token])
    render json: tokens, status: :ok
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
    RefreshToken.create_or_update(user.id, tokens[:refresh_token])
    render json: tokens, status: :ok
  end

  def logout
    refresh_token = @current_user.refresh_token
    refresh_token.destroy if refresh_token
    render json: { message: "로그아웃 성공" }, status: :ok
  end

  private
    # OTP 관련 파라미터 검증
    def validate_otp_params(email, otp)
      raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::EMAIL_REGEX)
      raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::OTP_REGEX)
    end

    # -------------------------------------------------------
    # 이메일로 사용자 조회 및 OTP 검증
    # -------------------------------------------------------
    def find_and_verify_user_otp(email, otp)
      user = User.find_by(email_address: email)
      raise CustomError, "사용자를 찾을 수 없습니다." unless user

      is_valid = user.verify_otp(otp)
      raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

      user
    end
end
