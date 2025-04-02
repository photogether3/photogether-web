class PostMetadatum < ApplicationRecord
  # 관계 설정
  belongs_to :post

  # 유효성 검증
  validates :content, presence: true, length: { in: 2..30 }
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :has_link, inclusion: { in: [ true, false ] }
end
