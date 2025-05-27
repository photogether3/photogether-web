class Auth::SocialLogin
  def initialize(
    provider: nil,
    provider_id: nil,
    provider_email: nil
  )
    @provider = provider
    @provider_id = provider_id
    @provider_email = provider_email
  end

  def call
    return Result.failure("프로바이더 타입이 누락되었습니다.", "BAD_REQUEST") if @provider.nil?
    return Result.failure("프로바이더 ID가 누락되었습니다.", "BAD_REQUEST") if @provider_id.nil?
    return Result.failure("이메일이 누락되었습니다.", "BAD_REQUEST") if @provider_email.nil?

    user = User.find_by(email_address: @provider_email)

    if user.nil?
      # 객체로 데이터 구성 후 URL 생성
      params = {
        code: "UNREGISTER",
        provider: @provider,
        providerId: @provider_id,
        providerEmail: @provider_email
      }

      app_scheme_url = build_app_scheme_url(params)
      return Result.success(app_scheme_url)
    end

    tokens = Auth::TokenManager.issue_tokens(user)

    if !user.social_match(@provider, @provider_id)
      user.provider = @provider
      user.provider_id = @provider_id
      user.save

      # 토큰 정보를 포함한 객체로 데이터 구성
      params = {
        code: "LOGIN_WITH_UPDATE",
        accessToken: tokens[:access_token],
        refreshToken: tokens[:refresh_token],
        expiresIn: tokens[:expires_in]
      }

      app_scheme_url = build_app_scheme_url(params)
      return Result.success(app_scheme_url)
    end

    # 일반 로그인 성공 시
    params = {
      code: "LOGIN",
      accessToken: tokens[:access_token],
      refreshToken: tokens[:refresh_token],
      expiresIn: tokens[:expires_in]
    }

    app_scheme_url = build_app_scheme_url(params)
    Result.success(app_scheme_url)
  end

  private

  # 객체에서 URL 쿼리 문자열 생성
  def build_app_scheme_url(params)
    query_string = params.map { |key, value|
      "#{key}=#{CGI.escape(value.to_s)}"
    }.join("&")

    "photogether://auth/success?#{query_string}"
  end
end
