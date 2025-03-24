class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    email    = params[:email] ||= ""
    password = params[:password] ||= ""

    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
    raise ArgumentError, "비밀번호를 입력해 주세요." if password.blank?

    user = User.find_by(email_address: email)

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    raise CustomError, err_msg unless user
    raise CustomError, err_msg if !user.authenticate(password)
    raise CustomError, "이메일 인증을 완료해주세요." unless user.is_email_verified

    tokens = create_tokens_with_save_effect(user.id)

    render json: tokens, status: :ok
  end

  def register
    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: params[:email],
        password: params[:password],
        password_confirmation: params[:password],
        role_id: 1,
        nickname: BaseUtil.generate_random_nickname,
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH",         title: "휴지통" }
      ])
    end
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    email = params[:email] ||= ""

    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)

    user = User.find_by(email_address: email)
    raise CustomError, "사용자를 찾을 수 없습니다." unless user

    user.update!(otp: BaseUtil.generate_otp, otp_expiry_date: 5.minutes.from_now)

    UserMailer.send_otp_email(user).deliver_now

    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    email = params[:email] ||= ""
    otp   = params[:otp] ||= ""

    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
    raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)

    user = User.find_by(email_address: email)
    raise CustomError, "사용자를 찾을 수 없습니다." unless user

    is_valid = user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    user.update!(otp: nil, otp_expiry_date: nil, is_email_verified: true)

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

  # - 사용자ID에 해당하는 토큰 리소스를 발급합니다.
  # - 사용자 토큰에 리프레시 토큰 정보를 저장합니다.
  # - 토큰 리소스를 반환합니다.
  def create_tokens_with_save_effect(user_id)
    tokens = JwtUtil.generate_tokens(user_id)
    RefreshToken.create_or_update_usecase(user_id, tokens[:refresh_token])

    tokens
  end
end
