class User::PasswordUpdater < BaseUseCase
  def initialize(current_user, params)
    @current_user = current_user
    @new_password = params[:newPassword]
    @otp          = params[:otp]
  end

  def call
    email    = params[:email]
    otp      = params[:otp]
    password = params[:password]

    return failure("유효한 이메일을 입력해 주세요.") unless email.match?(User::VALID_EMAIL_REGEX)
    return failure("OTP는 6자리 숫자여야 합니다.") unless otp.to_s.match?(User::VALID_OTP_REGEX)
    return failure("비밀번호를 입력해 주세요.") if password.blank?

    user = User.find_by(email_address: email)
    raise ActiveRecord::RecordNotFound, "사용자를 찾을 수 없습니다." unless user

    is_valid = user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    user.update!(
      password: password,
      password_confirmation: password,
      otp: nil,
      otp_expiry_date: nil,
    )
  end
end
