class Kakao::OauthService
  @@client_id = Rails.application.credentials.dig(:kakao, :client_id) || nil

  def initialize(
    redirect_uri: nil,
    code: nil
  )
    @redirect_uri = redirect_uri
    @code = code
  end

  # 엑세스토큰 발급 + 프로필 조회 기능 수행
  # 프로필 데이터 반환:
  # provider: KAKAO 고정
  # provider_id: 사용자의 카카오측에서 만든 ID
  # provider_email: 사용자의 카카오 이메일
  def call
    token_info_result = get_access_token
    return token_info_result if token_info_result.failure?

    user_info_result = get_user_info(token_info:  token_info_result.data)
    return user_info_result if user_info_result.failure?

    kakao_data = {
      provider: "kakao",
      provider_id: user_info_result.data["id"],
      provider_email: user_info_result.data&.dig("kakao_account", "email")
    }
    Result.success(kakao_data)
  end

  def get_access_token
    # 초기값 유효성 검증
    return Result.failure("클라이언트ID가 누락되었습니다.") if @@client_id.nil?
    return Result.failure("카카오 리다이렉트 URL이 누락되었습니다.") if @redirect_uri.nil?
    return Result.failure("인증코드가 누락되었습니다.") if @code.nil?

    response = Faraday.post("https://kauth.kakao.com/oauth/token") do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8"
      req.body = {
        grant_type: "authorization_code",
        client_id: @@client_id,
        redirect_uri: @redirect_uri,
        code: @code
      }
    end

    # 응답 처리
    unless response.status == 200
      puts "오류 발생: #{response.status} - #{response.body}"
      return Result.failure("오류 발생: #{response.status} - #{response.body}")
    end

    token_info = JSON.parse(response.body)
    puts "액세스 토큰: #{token_info['access_token']}"
    Result.success(token_info)
  end

  def get_user_info(token_info: nil)
    # 초기값 유효성 검증
    act = token_info&.dig("access_token")
    return Result.failure("엑세스토큰이 누락되었습니다.") unless act.present?

    response = Faraday.get("https://kapi.kakao.com/v2/user/me") do |req|
      req.headers["Authorization"] = "Bearer #{act}"
      req.headers["Content-Type"] = "application/x-www-form-urlencoded;charset=utf-8"
    end

    unless response.status == 200
      puts "사용자 정보를 가져올 수 없습니다: #{response.status}"
      return Result.failure("사용자 정보를 가져올 수 없습니다: #{response.status}")
    end

    Result.success(JSON.parse(response.body))
  end
end
