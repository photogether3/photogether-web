class Collection < ApplicationRecord
  # 제목에 대한 정규식 정의 - 2~20글자
  VALID_TITLE_REGEX = /\A.{2,20}\z/

  # 유효한 타입 정의
  VALID_TYPES = %w[DEFAULT UNCATEGORIZED TRASH].freeze

  # STI 비활성화
  self.inheritance_column = nil

  # 기본값 설정
  before_validation :set_default_type, if: -> { type.nil? }

  # 관계 설정
  belongs_to :user
  belongs_to :category, optional: true
  has_many :posts, dependent: :destroy

  # 유효성 검증
  validates :title, presence: true, format: {
    with: VALID_TITLE_REGEX,
    message: "제목은 2~20글자 사이여야 합니다."
  }
  validates :type, inclusion: {
    in: VALID_TYPES,
    message: "타입은 DEFAULT, UNCATEGORIZED, TRASH 중 하나여야 합니다."
  }

  # 스코프 메서드
  scope :with_posts_count, -> {
    select("collections.*, (SELECT COUNT(*) FROM posts WHERE posts.collection_id = collections.id) AS posts_count")
  }
  scope :default_type, -> { where(type: "DEFAULT") }
  scope :uncategorized, -> { where(type: "UNCATEGORIZED") }
  scope :trash, -> { where(type: "TRASH") }

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

  private

  def set_default_type
    self.type = "DEFAULT"
  end
end
