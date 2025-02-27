class Api::V1::AuthController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token

  def login
    # 예제 토큰 값 생성 (실제 구현에서는 JWT 토큰 생성 로직을 추가해야 함)
    access_token = "example_access_token"
    refresh_token = "example_refresh_token"
    expires_in = 3600 # 1시간 (초 단위)

    render_auth_response(access_token, refresh_token, expires_in)
  end

  def register
    # 요청값에서 필요한 데이터만 추출
    user_params = extract_user_params(params)
    puts user_params

    # 모델을 이용한 유효성 검사
    user = User.new(user_params)

    unless user.valid?
      puts "유효성 검사 실패"
      raise CustomException.new(
        422,
        "VALIDATION_ERROR",
        user.errors.full_messages.join(", ")
      )
    end

    # 유효성 검사 통과 후 회원가입 로직 (예: DB 저장)
    user.save!

    render json: { message: "회원가입 성공", user: user }, status: :created
  end


  def generate_otp
  end

  def verify_otp
  end

  def refresh
  end

  def logout
  end

  private
    # 🚨 요청에서 email과 password만 추출 (불필요한 값 제거)
    def extract_user_params(params)
      {
        email_address: params[:email], # 요청에서 email을 email_address로 매핑
        password: params[:password]
      }
    end
end
