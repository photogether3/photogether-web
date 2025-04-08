class Auth::OtpProcessor < BaseUseCase
  def initialize(params)
    @email    = params[:email] || ""
    @otp      = params[:otp] || nil
  end

  def generate(with_otp: false) # 프로세스가 끝날 때 otp 데이터를 반환할지 여부
    return failure("유효한 이메일을 입력해 주세요.") unless @email.match?(User::EMAIL_REGEX)

    user = User.find_by(email_address: @email)
    return failure("사용자를 찾을 수 없습니다.") unless user

    user.update_otp(generate_otp)
    UserMailer.send_otp_email(user).deliver_now

    success(with_otp ? user.otp : nil)
  end

  def verify
    # 검증 메서드 호출하여 실패 시 바로 반환
    verification_result = verify_otp
    return verification_result unless verification_result.success?

    success
  end

  def verify_and_generate_token
    # 검증 메서드 호출하여 실패 시 바로 반환
    verification_result = verify_otp
    return verification_result unless verification_result.success?

    # 검증 성공 후 추가 작업
    user = verification_result.data
    user.reset_otp { |u| u.is_email_verified = true }
    tokens = Auth::TokenManager.issue_tokens(user)

    success(tokens)
  end

  private
    # OTP 검증 공통 로직을 담당하는 메서드
    def verify_otp
      return failure("유효한 이메일을 입력해 주세요.") unless @email.match?(User::EMAIL_REGEX)
      return failure("OTP는 6자리 숫자여야 합니다.") unless @otp.to_s.match?(User::OTP_REGEX)

      user = User.find_by(email_address: @email)
      return failure("사용자를 찾을 수 없습니다.") unless user

      unless user.verify_otp(@otp)
        return failure("OTP가 일치하지 않습니다.")
      end

      # 검증 성공 시 사용자 객체 반환
      success(user)
    end

    # 6자리 숫자 문자열 (100000~999999)
    def generate_otp
      (100_000 + rand(900_000)).to_s
    end
end
