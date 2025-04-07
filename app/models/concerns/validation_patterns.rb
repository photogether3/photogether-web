module ValidationPatterns
  extend ActiveSupport::Concern

  # 이메일 정규식: 6~50자 길이 제한 포함
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # 비밀번호 정규식: 최소 8자, 최대 50자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함
  PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,50}\z/

  # OTP 정규식: 6자리 숫자
  OTP_REGEX = /\A\d{6}\z/

  # 닉네임 정규식: 2~20자 영문, 숫자, 한글, 공백 허용
  NICKNAME_REGEX = /\A[a-zA-Z0-9가-힣\s]{2,20}\z/

  # 카테고리 정규식: 2~20자 영문, 숫자, 한글, 특수문자 가능
  CATEGORY_REGEX = /\A[a-zA-Z0-9가-힣!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/? ]{2,20}\z/
end
