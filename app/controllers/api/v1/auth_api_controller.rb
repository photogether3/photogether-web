class Api::V1::AuthApiController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    email = params[:email].to_s.strip
    password = params[:password].to_s

    # 입력값 검증
    validate_login_inputs(email, password)

    # 사용자 조회 및 검증
    user = find_and_validate_user(email, password)

    # 토큰 생성 및 응답
    tokens = create_tokens_with_save_effect(user.id)
    render json: tokens, status: :ok
  end

  def register
    # 사용자 속성 준비
    user_attributes = prepare_user_attributes

    # 사용자 생성 (기본 컬렉션 포함)
    User.create_with_default_collections(user_attributes)
    render json: { message: "회원가입 성공" }, status: :created
  end

  def generate_otp
    email = params[:email].to_s.strip

    # 이메일 유효성 검증
    validate_email(email)

    # 사용자 조회
    user = find_user_by_email(email)

    # OTP 생성 및 저장
    generate_and_save_otp(user)

    # 이메일 발송
    UserMailer.send_otp_email(user).deliver_now

    render json: { message: "OTP 발급 성공" }, status: :created
  end

  def verify_otp
    email = params[:email].to_s.strip
    otp = params[:otp].to_s

    # OTP 파라미터 검증
    validate_otp_input(email, otp)

    # 사용자 찾기 및 OTP 검증
    find_and_verify_user_otp(email, otp)

    render json: { message: "OTP 검증 성공" }, status: :ok
  end

  def verify_otp_with_generate_token
    email = params[:email].to_s.strip
    otp = params[:otp].to_s

    # OTP 파라미터 검증
    validate_otp_input(email, otp)

    # 사용자 찾기 및 OTP 검증
    user = find_and_verify_user_otp(email, otp)

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
    # 리프레시 토큰 추출
    refresh_token = extract_refresh_token

    # 토큰 모델 조회 및 검증
    refresh_token_model = validate_refresh_token(refresh_token)

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

    # 로그인 입력값 검증
    def validate_login_inputs(email, password)
      raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
      raise ArgumentError, "비밀번호를 입력해 주세요." if password.blank?
    end

    # 사용자 조회 및 검증
    def find_and_validate_user(email, password)
      user = User.find_by(email_address: email)

      err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
      raise CustomError, err_msg unless user
      raise CustomError, err_msg unless user.authenticate(password)
      raise CustomError, "이메일 인증을 완료해주세요." unless user.is_email_verified

      user
    end

    # 사용자 속성 준비
    def prepare_user_attributes
      {
        email_address: params[:email],
        password: params[:password],
        password_confirmation: params[:password],
        role_id: 1,
        nickname: BaseUtil.generate_random_nickname
      }
    end

    # 이메일 유효성 검증
    def validate_email(email)
      raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
    end

    # 이메일로 사용자 조회
    def find_user_by_email(email)
      user = User.find_by(email_address: email)
      raise CustomError, "사용자를 찾을 수 없습니다." unless user
      user
    end

    # OTP 생성 및 저장
    def generate_and_save_otp(user)
      user.update!(
        otp: BaseUtil.generate_otp,
        otp_expiry_date: 5.minutes.from_now
      )
    end

    # OTP 입력값 검증
    def validate_otp_input(email, otp)
      raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
      raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.match?(User::VALID_OTP_REGEX)
    end

    # 사용자 찾기 및 OTP 검증
    def find_and_verify_user_otp(email, otp)
      user = User.find_by(email_address: email)
      raise CustomError, "사용자를 찾을 수 없습니다." unless user

      is_valid = user.verify_otp(otp)
      raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

      user
    end

    # 리프레시 토큰 추출
    def extract_refresh_token
      refresh_token = request.headers["x-refresh-token"]
      raise CustomError, "리프레시 토큰이 없습니다." if refresh_token.blank?
      refresh_token
    end

    # 리프레시 토큰 검증
    def validate_refresh_token(refresh_token)
      refresh_token_model = RefreshToken.find_by(refresh_token: refresh_token)

      err_msg = "리프레시 토큰이 유효하지 않습니다."
      raise CustomError, err_msg unless refresh_token_model
      raise CustomError, err_msg if refresh_token_model.expiry_date < Time.current

      refresh_token_model
    end

    # 토큰 생성 및 저장
    def create_tokens_with_save_effect(user_id)
      tokens = JwtUtil.generate_tokens(user_id)
      RefreshToken.create_or_update(user_id, tokens[:refresh_token])
      tokens
    end
end
