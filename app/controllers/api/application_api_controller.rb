class Api::ApplicationApiController < ActionController::API
  # 모든 예외를 한 메서드에서 처리
  rescue_from StandardError, with: :handle_api_error

  protected

  def render_auth_response(access_token, refresh_token, expires_in)
    render json: {
      accessToken: access_token,
      refreshToken: refresh_token,
      expiresIn: expires_in
    }
  end

  private

  def handle_api_error(exception)
    Rails.logger.error "Caught exception: #{exception.class}"
    Rails.logger.error(exception.message)

    case exception
    when ActiveRecord::RecordInvalid
      # RecordInvalid(주로 유효성 검증 실패)
      record  = exception.record
      message = record&.errors&.full_messages&.join(", ") || exception.message

      render json: {
        errorCode: 400,
        code: "VALIDATION_ERROR",
        message: message
      }, status: 400

    when ActiveRecord::RecordNotFound
      # RecordNotFound(레코드를 찾을 수 없음)
      render json: {
        errorCode: 400,
        code: "NOTFOUND_ERROR",
        message: exception.message
      }, status: 400

    when ArgumentError
      # ArgumentError(잘못된 인자, 파라미터 에러 등)
      render json: {
        errorCode: 400,
        code: "ARGUMENT_ERROR",
        message: exception.message
      }, status: 400

    else
      # 그 외 모든 예외(범용 처리)
      render json: {
        errorCode: 500,
        code: "INTERNAL_SERVER_ERROR",
        message: "무언가 잘못됐어요."
      }, status: 500
    end
  end
end
