class Auth::Login
  def initialize(params)
    @email    = params[:email] || ""
    @password = params[:password] || ""
  end

  def call
    return Result.failure("유효한 이메일을 입력해 주세요.", "INVALID_EMAIL") unless @email.match?(ValidationPatterns::EMAIL_REGEX)
    return Result.failure("비밀번호를 입력해 주세요.", "MISSING_PASSWORD") if @password.blank?

    user = User.find_by(email_address: @email, provider: "email")

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    return Result.failure(err_msg, "INVALID_CREDENTIALS") unless user
    return Result.failure(err_msg, "INVALID_CREDENTIALS") if !user.authenticate(@password)
    return Result.failure("이메일 인증을 완료해주세요.", "EMAIL_NOT_VERIFIED") unless user.is_email_verified

    tokens = Auth::TokenManager.issue_tokens(user)

    Result.success(tokens)
  end
end
