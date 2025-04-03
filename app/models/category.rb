class Category < ApplicationRecord
  # 한글, 영문, 숫자, 특수문자 허용하는 정규식 (최소 2글자, 최대 20글자)
  VALID_NAME_REGEX = /\A[\p{L}\p{N}\p{P}\p{S}\s]{2,20}\z/

  # 관계 설정
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  # 유효성 검증
  validates :name, presence: { message: "카테고리 이름을 입력해주세요." }
  validates :name, format: {
    with: VALID_NAME_REGEX,
    message: "카테고리 이름은 2~20글자의 문자, 숫자, 특수문자를 사용할 수 있습니다."
  }, allow_blank: true
end
