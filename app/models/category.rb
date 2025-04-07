class Category < ApplicationRecord
  include ValidationPatterns

  # ------------------------------------------------------
  # 관계 설정
  # ------------------------------------------------------
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  # ------------------------------------------------------
  # 유효성 검사 (카테고리 이름)
  # ------------------------------------------------------
  validates :name, presence: { message: "카테고리 이름을 입력해주세요." }
  validates :name, presence: { message: "카테고리 이름을 입력해주세요." },
  format: {
    with: CATEGORY_REGEX,
    message: "카테고리 이름은 2~20글자의 영문, 숫자, 한글, 특수문자만 사용 가능합니다."
  }
end
