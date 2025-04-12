class Auth::Login < BaseService
  def initialize(params)
    @email    = params[:email] || ""
    @password = params[:password] || ""
  end

  def call
    return failure("유효한 이메일을 입력해 주세요.") unless @email.match?(ValidationPatterns::EMAIL_REGEX)
    return failure("비밀번호를 입력해 주세요.") if @password.blank?

    user = User.find_by(email_address: @email)

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    return failure(err_msg) unless user
    return failure(err_msg) if !user.authenticate(@password)
    return failure("이메일 인증을 완료해주세요.") unless user.is_email_verified

    tokens = Auth::TokenManager.issue_tokens(user)

    success(tokens)
  end
end
