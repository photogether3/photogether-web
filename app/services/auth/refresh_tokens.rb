class Auth::RefreshTokens
  def initialize(refresh_token)
    @refresh_token = refresh_token
  end

  def call
    return Result.failure("리프레시 토큰이 없습니다.") if @refresh_token.blank?

    refresh_token_model = RefreshToken.find_by(refresh_token: @refresh_token)
    error_message = "리프레시 토큰이 유효하지 않습니다."
    return Result.failure(error_message) unless refresh_token_model
    return Result.failure(error_message) if refresh_token_model.expired?

    user = refresh_token_model.user
    tokens = Auth::TokenManager.issue_tokens(user)

    Result.success(tokens)
  end
end
