class Api::V1::AuthApiController < ApiController
  before_action :authenticate_user!, only: [ :logout ]

  def login
    result = Auth::Login.new(params).call
    render_result(result, success_status: :ok)
  end

  def register
    result = User::Register.new(params)
      .without_user
      .call
    render_result(result, success_status: :created)
  end

  def generate_otp
    result = Auth::Otp.new(params).generate
    render_result(result, success_status: :ok)
  end

  def verify_otp
    result = Auth::Otp.new(params).verify
    render_result(result, success_status: :ok)
  end

  def verify_otp_with_generate_token
    result = Auth::Otp.new(params).verify(with_tokens: true)
    render_result(result, success_status: :ok)
  end

  def refresh
    refresh_token = request.headers["x-refresh-token"]
    result = Auth::RefreshTokens.new(refresh_token).call
    render_result(result, success_status: :ok)
  end

  def logout
    refresh_token = @current_user.refresh_token
    refresh_token.destroy if refresh_token
    render json: { message: "로그아웃 성공" }, status: :ok
  end
end
