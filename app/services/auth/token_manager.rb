# 이 파일은 인증과 관련된 서비스로, 사용자의 ID를 기반으로 JWT 토큰을 생성하고,
# 해당 토큰을 데이터베이스에 저장하는 기능을 제공합니다.

require "jwt"
require "securerandom"

module Auth
  class TokenManager
    APP_KEY = Rails.application.credentials.secret_key_base
    ALGORITHM = "HS256"

    # [1] access_token + refresh_token 발급 + refresh 저장
    def self.issue_tokens(user)
      tokens = generate_tokens(user.id)
      RefreshToken.create_or_update(user.id, tokens[:refresh_token])
      tokens
    end

    # [2] access_token + refresh_token만 발급 (DB 저장은 안 함)
    def self.generate_tokens(user_id)
      exp = 1.hour.from_now.to_i

      payload = {
        sub: user_id.to_s,
        exp: exp
      }

      access_token = JWT.encode(payload, APP_KEY, ALGORITHM)
      refresh_token = SecureRandom.uuid

      tokens = {
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: exp
      }
      puts "발급된 토큰: #{tokens.inspect}"
      tokens
    end

    # [3] access_token 디코딩
    def self.decode_token(token)
      decoded = JWT.decode(token, APP_KEY, true, algorithm: ALGORITHM)
      decoded[0]  # payload만 반환
    rescue JWT::DecodeError
      nil
    end
  end
end
