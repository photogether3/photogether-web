class Auth::TokenRefresher < BaseUseCase
  def initialize(refresh_token)
    @refresh_token = refresh_token
  end

  def call
    return failure("리프레시 토큰이 없습니다.") if @refresh_token.blank?

    refresh_token_model = RefreshToken.find_by(refresh_token: @refresh_token)
    return failure("리프레시 토큰이 유효하지 않습니다.") unless refresh_token_model

    if refresh_token_model.expiry_date < Time.current
      return failure("리프레시 토큰이 유효하지 않습니다.")
    end

    user = refresh_token_model.user
    tokens = Auth::TokenManager.issue_tokens(user)

    success(tokens)
  end
end
