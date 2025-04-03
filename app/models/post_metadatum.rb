class PostMetadatum < ApplicationRecord
  # 관계 설정
  belongs_to :post

  # 유효성 검증
  validates :content, presence: true, length: { in: 1..30 }
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :has_link, inclusion: { in: [ true, false ] }

  # 주어진 메타데이터 배열에서 여러 개의 메타데이터 레코드 생성
  def self.create_from_array!(post, metadata_list)
    return [] if metadata_list.blank?

    metadata_attributes = metadata_list.map do |metadata|
      {
        post_id: post.id,
        content: metadata["content"],
        is_public: metadata["isPublic"] || false,
        has_link: metadata["hasLink"] || false,
        rank: metadata["rank"] || 1
      }
    end

    create!(metadata_attributes)
  end

  # 메타데이터를 해시로 변환 (to_detail 메서드에서 사용)
  def to_hash
    {
      content: content,
      is_public: is_public,
      has_link: has_link,
      rank: rank
    }
  end

  # 첫 번째 메타데이터에서 제목으로 사용할 내용 추출
  def self.extract_title_from_metadata(metadata_list, max_length = 50)
    return nil if metadata_list.blank? || metadata_list.first["content"].blank?

    metadata_list.first["content"].truncate(max_length)
  end
end
