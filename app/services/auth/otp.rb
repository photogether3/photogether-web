class Auth::Otp
  def initialize(params)
    @email    = params[:email] || ""
    @otp      = params[:otp] || nil
  end

  def generate(with_otp: false) # 프로세스가 끝날 때 otp 데이터를 반환할지 여부
    return Result.failure("유효한 이메일을 입력해 주세요.") unless @email.match?(ValidationPatterns::EMAIL_REGEX)

    user = User.find_by(email_address: @email, provider: "email")
    return Result.failure("사용자를 찾을 수 없습니다.") unless user

    user.update_otp(generate_otp)
    UserMailer.send_otp_email(user).deliver_now

    Result.success(with_otp ? user.otp : nil)
  end

  def verify(with_tokens: false)
    # 검증 메서드 호출하여 실패 시 바로 반환
    return Result.failure("유효한 이메일을 입력해 주세요.") unless @email.match?(ValidationPatterns::EMAIL_REGEX)
    return Result.failure("OTP는 6자리 숫자여야 합니다.") unless @otp.to_s.match?(ValidationPatterns::OTP_REGEX)

    user = User.find_by(email_address: @email, provider: "email")
    return Result.failure("사용자를 찾을 수 없습니다.") unless user

    unless user.verify_otp(@otp)
      return Result.failure("OTP가 일치하지 않습니다.")
    end

    if with_tokens
      user.reset_otp { |u| u.is_email_verified = true }
      tokens = Auth::TokenManager.issue_tokens(user)
      return Result.success(tokens)
    end

    Result.success
  end

  private

    # 6자리 숫자 문자열 (100000~999999)
    def generate_otp
      (100_000 + rand(900_000)).to_s
    end
end
