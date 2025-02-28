# app/services/jwt_util.rb

require "jwt"
require "securerandom"

class JwtUtil
  # Rails의 secret_key_base나 별도의 환경변수를 사용합니다.
  APP_KEY = Rails.application.credentials.secret_key_base

  # user_id를 받아 access_token, refresh_token, expires_in 값을 반환
  def self.generate_tokens(user_id)
    # 1시간 후 만료 (초 단위)
    exp = 1.hours.from_now.to_i

    # JWT payload에 subject (sub)와 만료 시간 (exp) 포함
    payload = { sub: user_id.to_s, exp: exp }

    # HS256 알고리즘으로 access token 생성
    access_token = JWT.encode(payload, APP_KEY, "HS256")

    # refresh token은 SecureRandom.uuid를 이용해 생성
    refresh_token = SecureRandom.uuid

    { access_token: access_token, refresh_token: refresh_token, expires_in: exp }
  end
end
