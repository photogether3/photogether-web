class Api::ApplicationApiController < ActionController::API
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid

  protected

  def render_auth_response(access_token, refresh_token, expires_in)
    render json: {
      accessToken: access_token,
      refreshToken: refresh_token,
      expiresIn: expires_in
    }
  end

  private

  def handle_record_invalid(exception)
    record  = exception.record
    message = record&.errors&.full_messages&.join(", ") || exception.message

    render json: {
      errorCode: 400,
      code: "VALIDATION_ERROR",
      message: message
    }, status: 400
  end

  def handle_standard_error(exception)
    Rails.logger.error "Caught exception: #{exception.class}"
    Rails.logger.error(exception.message)

    render json: {
      errorCode: 500,
      code: "INTERNAL_SERVER_ERROR",
      message: "무언가 잘못됐어요."
    }, status: 500
  end
end
