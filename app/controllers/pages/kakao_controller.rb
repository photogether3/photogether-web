class Pages::KakaoController < PagesController
  layout false

  def index
    @javascript_key = Rails.application.credentials.dig(:kakao, :javascript_key)
    @redirect_uri = kakao_redirect_url
  end

  def redirect
    client_id = Rails.application.credentials.dig(:kakao, :client_id)
    code = params[:code]

    # 카카오 OAuth 토큰 요청
    response = Faraday.post("https://kauth.kakao.com/oauth/token") do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8"
      req.body = {
        grant_type: "authorization_code",
        client_id: client_id,
        redirect_uri: kakao_redirect_url,
        code: code
      }
    end

    # 응답 처리
    if response.status == 200
      token_info = JSON.parse(response.body)
      puts "액세스 토큰: #{token_info['access_token']}"

      # 사용자 정보 요청
      user_info = get_kakao_user_info(token_info["access_token"])
      puts "카카오 사용자 정보: #{user_info}"

      # 여기서 로그인 처리 또는 회원가입 등의 로직 진행...
    else
      puts "오류 발생: #{response.status} - #{response.body}"
    end
  end

  private

  def get_kakao_user_info(access_token)
    response = Faraday.get("https://kapi.kakao.com/v2/user/me") do |req|
      req.headers["Authorization"] = "Bearer #{access_token}"
      req.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8"
    end

    if response.status == 200
      JSON.parse(response.body)
    else
      { error: "사용자 정보를 가져올 수 없습니다: #{response.status}" }
    end
  end
end
