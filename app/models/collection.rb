class Collection < ApplicationRecord
  # self.inheritance_column = nil은 ActiveRecord에서
  # STI(Single Table Inheritance)를 비활성화하기 위해 사용됩니다.
  # 기본적으로 ActiveRecord는 type이라는 컬럼을 사용하여 STI를 구현합니다.
  # 즉, type 컬럼을 사용하여 상속된 클래스의 이름을 저장하고,
  # 이를 통해 상속된 클래스의 인스턴스를 생성합니다.
  # 하지만, type 컬럼을 다른 용도로 사용하고 싶거나,
  # STI를 사용하지 않으려는 경우 self.inheritance_column을 nil로 설정하여
  # ActiveRecord가 type 컬럼을 무시하도록 할 수 있습니다.
  self.inheritance_column = nil

  belongs_to :user
  belongs_to :category, optional: true

  has_many :posts, dependent: :destroy

  validates :title, presence: true, length: { in: 2..50 }

  scope :with_posts_count, -> {
    select("collections.*, (SELECT COUNT(*) FROM posts WHERE posts.collection_id = collections.id) AS posts_count")
  }

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
