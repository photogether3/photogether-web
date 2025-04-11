class User::OtpPasswordUpdateUseCase < BaseUseCase
  def initialize(params)
    @email = params[:email]
    @otp = params[:otp]
    @new_password = params[:newPassword]
  end

  def call
    # 유효성 검증
    return failure("유효한 이메일을 입력해 주세요.") unless valid_email?
    return failure("OTP는 6자리 숫자여야 합니다.") unless valid_otp_format?
    return failure("새 비밀번호를 입력해 주세요.") if @new_password.blank?
    return failure("비밀번호는 최소 8자, 최대 50자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함") unless valid_password_format?

    # 사용자 조회
    user = find_user
    return failure("사용자를 찾을 수 없습니다.") unless user

    # OTP 검증
    unless user.verify_otp(@otp)
      return failure("OTP가 유효하지 않습니다.")
    end

    # 비밀번호 업데이트 및 OTP 초기화
    update_password(user)
  end

  private

  def valid_email?
    @email.to_s.match?(ValidationPatterns::EMAIL_REGEX)
  end

  def valid_otp_format?
    @otp.to_s.match?(ValidationPatterns::OTP_REGEX)
  end

  def valid_password_format?
    @new_password.to_s.match?(ValidationPatterns::PASSWORD_REGEX)
  end

  def find_user
    User.find_by(email_address: @email)
  end

  def update_password(user)
    if user.update(
      password: @new_password,
      password_confirmation: @new_password,
      otp: nil,
      otp_expiry_date: nil
    )
      success(message: "비밀번호가 성공적으로 변경되었습니다.")
    else
      failure("비밀번호 변경에 실패했습니다: #{user.errors.full_messages.join(', ')}")
    end
  end
end
