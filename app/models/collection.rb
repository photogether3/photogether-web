class Collection < ApplicationRecord
  # STI(Single Table Inheritance)를 비활성화하기 위해 사용됩니다.
  self.inheritance_column = nil

  # ------------------------------------------------------
  # 관계 설정
  # ------------------------------------------------------
  belongs_to :user
  belongs_to :category, optional: true
  has_many :posts, dependent: :destroy

  # ------------------------------------------------------
  # 유효성 검사 (사진첩 제목)
  # ------------------------------------------------------
  validates :title, presence: true, length: { in: 2..50 }

  # ------------------------------------------------------
  # 스코프 설정
  # ------------------------------------------------------
  scope :with_posts_count, -> {
    select("collections.*, (SELECT COUNT(*) FROM posts WHERE posts.collection_id = collections.id) AS posts_count")
  }

  # ------------------------------------------------------
  # 상세 반환타입
  # ------------------------------------------------------
  def to_detail
    {
      id: id,
      title: title,
      type: type,
      category: category ? { id: category.id, name: category.name } : nil,
      post_count: attributes["posts_count"].to_i,
      image_urls: [], # 컨트롤러에서 merge로 추가
      created_at: created_at.iso8601(3),
      updated_at: updated_at.iso8601(3)
    }
  end
end
