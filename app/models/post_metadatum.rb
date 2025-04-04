class PostMetadatum < ApplicationRecord
  # 관계 설정
  belongs_to :post

  # 유효성 검증
  validates :content, presence: true, length: { in: 1..30 }
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :has_link, inclusion: { in: [ true, false ] }

  def self.create_from_array!(post, metadata_list)
    return [] if metadata_list.blank?

    # map.with_index를 사용하여 배열 생성
    metadata_attributes = metadata_list.map.with_index do |metadata, index|
      # 문자열 키를 가진 해시로 변환
      metadata = metadata.transform_keys(&:to_s) if metadata.is_a?(Hash)

      {
        post_id: post.id,
        content: metadata["content"] || "",
        is_public: !!metadata["isPublic"], # 확실히 boolean으로 변환
        has_link: !!metadata["hasLink"],   # 확실히 boolean으로 변환
        rank: index + 1
      }
    end

    create!(metadata_attributes)
  end

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
