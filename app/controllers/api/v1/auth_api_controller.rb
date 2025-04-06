class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    tokens = Auth::Login.call(params)
    render json: tokens, status: :ok
  end

  def register
    User.register(params)
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    email = params[:email] ||= ""
    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(EMAIL_REGEX)
    user = self.find_by(email_address: email)
    raise CustomError, "사용자를 찾을 수 없습니다." unless user

    user.update_otp
    UserMailer.send_otp_email(user).deliver_now
    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    # 직접 메서드 호출
    email = params[:email] ||= ""
    otp = params[:otp] ||= ""

    self.validate_otp_params(email, otp)
    find_and_verify_user_otp(email, otp)

    render json: { message: "OTP 검증 성공" }, status: :ok
  end

  def verify_otp_with_generate_token
    email = params[:email] ||= ""
    otp   = params[:otp] ||= ""

    validate_otp_params(email, otp)
    user = find_and_verify_user_otp(email, otp)

    user.reset_otp { |u| u.is_email_verified = true }

    tokens = create_tokens_with_save_effect(user.id)
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
    tokens = create_tokens_with_save_effect(user.id)

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
      raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
      raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)
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
