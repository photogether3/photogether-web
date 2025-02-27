class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from StandardError, with: :handle_standard_error

  protected

  def render_auth_response(access_token, refresh_token, expires_in)
    render json: {
      accessToken: access_token,
      refreshToken: refresh_token,
      expiresIn: expires_in
    }
  end

  # 🚨 필수 값 검증 메서드
  def validate_required_params!(params, *keys)
    keys.each do |key|
      if params[key].blank?
        raise CustomException.new(error_code: 400, code: "BAD_REQUEST", message: "#{key}이(가) 누락되었습니다.")
      end
    end
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error exception.full_message # 서버 로그에 상세 정보 출력

    error_response = if exception.is_a?(CustomException)
      {
        errorCode: exception.error_code,
        code: exception.code,
        message: exception.message
      }
    else
      {
        errorCode: 500,
        code: "INTERNAL_SERVER_ERROR",
        message: "무언가 잘못됐어요."
      }
    end

    render json: error_response, status: error_response[:errorCode]
  end
end
