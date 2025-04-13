class PostMetadatum < ApplicationRecord
  # ---------------------------------------------------------------
  # 관계 설정
  # ---------------------------------------------------------------
  belongs_to :post

  # ---------------------------------------------------------------
  # 유효성 검증
  # ---------------------------------------------------------------
  validates :content, presence: true, length: { in: 1..30 }
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :has_link, inclusion: { in: [ true, false ] }

  # 출력용 해시 형태는 일관된 형식으로 제공
  def to_hash
    {
      content: content,
      is_public: is_public,
      has_link: has_link,
      rank: rank
    }
  end
end
