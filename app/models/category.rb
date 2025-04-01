class Category < ApplicationRecord
  # 한글 및 영문만 허용하는 정규식 (최소 2글자, 최대 20글자)
  VALID_NAME_REGEX = /\A[가-힣a-zA-Z]{2,20}\z/

  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  validates :name, presence: { message: "카테고리 이름을 입력해주세요." }
  validates :name, format: {
    with: VALID_NAME_REGEX,
    message: "카테고리 이름은 2~20글자의 한글 또는 영문만 사용 가능합니다."
  }, allow_blank: true
end
