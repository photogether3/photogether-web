class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    # 이메일/비밀번호 자격 증명 객체 생성
    credential = EmailPasswordCredential.new(params[:email], params[:password])

    # 유효성 검증
    error = credential.validation_error
    raise CustomError, error if error

    # 인증 수행
    user = credential.authenticate

    # 토큰 생성 및 응답
    tokens = create_tokens_with_save_effect(user.id)
    render json: tokens, status: :ok
  end

  def register
    Users::CreationStrategy.new(params)
      .add_policies()
      .create()
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    # 이메일만 포함하는 자격 증명 객체 생성
    credential = EmailOnlyCredential.new(params[:email])

    # 유효성 검증
    error = credential.validation_error
    raise CustomError, error if error

    # 사용자 조회
    user = credential.find_user

    # OTP 생성 및 저장
    generate_and_save_otp(user)

    # 이메일 발송
    UserMailer.send_otp_email(user).deliver_now

    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    # OTP 자격 증명 객체 생성
    credential = OtpCredential.new(params[:email], params[:otp])

    # 유효성 검증
    error = credential.validation_error
    raise CustomError, error if error

    # 인증 수행
    credential.authenticate

    render json: { message: "OTP 검증 성공" }, status: :ok
  end

  def verify_otp_with_generate_token
    # OTP 자격 증명 객체 생성
    credential = OtpCredential.new(params[:email], params[:otp])

    # 유효성 검증
    error = credential.validation_error
    raise CustomError, error if error

    # 인증 수행
    user = credential.authenticate

    # OTP 사용 후 초기화 및 이메일 인증 완료 처리
    user.update!(
      otp: nil,
      otp_expiry_date: nil,
      is_email_verified: true
    )

    # 토큰 생성 및 응답
    tokens = create_tokens_with_save_effect(user.id)
    render json: tokens, status: :created
  end

  def refresh
    # 리프레시 토큰 자격 증명 객체 생성
    credential = RefreshTokenCredential.new(request.headers["x-refresh-token"])

    # 유효성 검증
    error = credential.validation_error
    raise CustomError, error if error

    # 인증 수행
    refresh_token_model = credential.authenticate

    # 새 토큰 생성 및 응답
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

    # 사용자 속성 준비
    def prepare_user_attributes
      permitted = params.permit(:email, :password, :nickname)

      {
        email_address: permitted[:email],
        password: permitted[:password],
        password_confirmation: permitted[:password],
        role_id: 1,
        nickname: permitted[:nickname].presence || BaseUtil.generate_random_nickname
      }
    end

    # OTP 생성 및 저장
    def generate_and_save_otp(user)
      user.update!(
        otp: BaseUtil.generate_otp,
        otp_expiry_date: 5.minutes.from_now
      )
    end

    # 토큰 생성 및 저장
    def create_tokens_with_save_effect(user_id)
      tokens = JwtUtil.generate_tokens(user_id)
      RefreshToken.create_or_update(user_id, tokens[:refresh_token])
      tokens
    end
end
