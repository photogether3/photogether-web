class Favorite < ApplicationRecord
  # 관계 설정
  belongs_to :user
  belongs_to :category

  # 유효성 검증
  validates :user_id, presence: { message: "사용자 ID는 필수입니다." }
  validates :category_id, presence: { message: "카테고리 ID는 필수입니다." }

  # 동일한 사용자-카테고리 조합의 중복 방지
  validates :user_id, uniqueness: {
    scope: :category_id,
    message: "이미 즐겨찾기에 추가된 카테고리입니다."
  }
end
