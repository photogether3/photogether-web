class Pages::KakaoController < PagesController
  layout false

  def index
    client_id = Rails.application.credentials.dig(:kakao, :client_id)
    redirect_uri = kakao_redirect_url
    redirect_to "https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}",
                status: :see_other,
                allow_other_host: true  # 외부 호스트 리디렉션 허용
  end

  def redirect
    result = Kakao::OauthService.new(
      code: params[:code],
      redirect_uri: kakao_redirect_url
    ).call

    provider = result.data&.dig(:provider)
    provider_id = result.data&.dig(:provider_id)
    provider_email = result.data&.dig(:provider_email)

    login_result = Auth::SocialLogin.new(
      provider: provider,
      provider_id: provider_id,
      provider_email: provider_email
    ).call

    puts login_result.inspect

    @login_data = login_result.data
  end
end
