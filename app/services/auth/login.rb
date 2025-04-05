module Auth
  class Login
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @email    = params[:email]
      @password = params[:password]
    end

    def call
      raise CustomError, "유효한 이메일을 입력해 주세요." unless @email.match?(User::VALID_EMAIL_REGEX)
      raise ArgumentError, "비밀번호를 입력해 주세요." if @password.blank?

      user = User.find_by(email_address: @email)

      err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
      raise CustomError, err_msg unless user
      raise CustomError, err_msg if !user.authenticate(@password)
      raise CustomError, "이메일 인증을 완료해주세요." unless user.is_email_verified

      tokens = JwtUtil.generate_tokens(user.id)
      RefreshToken.create_or_update(user.id, tokens[:refresh_token])

      tokens
    end
  end
end
