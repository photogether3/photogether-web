class Auth::TokenRefreshUseCase < BaseUseCase
  def initialize(refresh_token)
    @refresh_token = refresh_token
  end

  def call
    return failure("리프레시 토큰이 없습니다.") if @refresh_token.blank?

    refresh_token_model = RefreshToken.find_by(refresh_token: @refresh_token)
    error_message = "리프레시 토큰이 유효하지 않습니다."
    return failure(error_message) unless refresh_token_model
    return failure(error_message) if refresh_token_model.expired?

    user = refresh_token_model.user
    tokens = Auth::TokenManager.issue_tokens(user)

    success(tokens)
  end
end
