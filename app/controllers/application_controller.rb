class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def render_auth_response(access_token, refresh_token, expires_in)
    render json: {
      accessToken: access_token,
      refreshToken: refresh_token,
      expiresIn: expires_in
    }
  end
end
