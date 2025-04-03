class PostMetadatum < ApplicationRecord
  # 관계 설정
  belongs_to :post

  # 유효성 검증
  validates :content, presence: true, length: { in: 1..30 }
  validates :is_public, inclusion: { in: [ true, false ] }
  validates :has_link, inclusion: { in: [ true, false ] }

  def self.create_from_array!(post, metadata_list)
    return [] if metadata_list.blank?

    metadata_attributes = metadata_list.each_with_index do |metadata, index|
      let rank_value = index + 1

      {
        post_id: post.id,
        content: extract_value(metadata, :content),
        is_public: extract_value(metadata, :is_public) || false,
        has_link: extract_value(metadata, :has_link) || false,
        rank: rank_value
      }
    end

    create!(metadata_attributes)
  end

  # 다양한 키 형식에서 값 추출 (카멜케이스, 스네이크케이스, 문자열, 심볼 모두 지원)
  def self.extract_value(hash, standard_key)
    standard_key = standard_key.to_s

    # 1. 스네이크 케이스 문자열/심볼 시도
    return hash[standard_key] if hash.key?(standard_key)
    return hash[standard_key.to_sym] if hash.key?(standard_key.to_sym)

    # 2. 카멜 케이스 변환 후 시도
    camel_key = standard_key.camelize(:lower)
    return hash[camel_key] if hash.key?(camel_key)
    return hash[camel_key.to_sym] if hash.key?(camel_key.to_sym)

    # 3. 원래 해시에서 string/symbol 키로 한번 더 시도
    hash.each do |k, v|
      # 문자열 키 정규화 후 비교
      k_str = k.to_s.underscore
      return v if k_str == standard_key
    end

    nil
  end

  # 첫 번째 메타데이터에서 제목으로 사용할 내용 추출
  def self.extract_title_from_metadata(metadata_list, max_length = 50)
    return nil if metadata_list.blank?

    first_metadata = metadata_list.first
    content = extract_value(first_metadata, :content)
    return nil if content.blank?

    content.truncate(max_length)
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
