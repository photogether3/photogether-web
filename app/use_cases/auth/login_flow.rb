class Auth::LoginFlow < BaseUseCase
  def initialize(email, password)
    @params = {
      email: email,
      password: password
    }
  end

  def call
    return failure("유효한 이메일을 입력해 주세요.") unless @params[:email].match?(User::EMAIL_REGEX)
    return failure("비밀번호를 입력해 주세요.") if @params[:password].blank?

    user = User.find_by(email_address: @params[:email])

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    return failure(err_msg) unless user
    return failure(err_msg) if !user.authenticate(@params[:password])
    return failure("이메일 인증을 완료해주세요.") unless user.is_email_verified

    tokens = JwtUtil.generate_tokens(user.id)
    RefreshToken.create_or_update(user.id, tokens[:refresh_token])

    success(tokens)
  end
end
