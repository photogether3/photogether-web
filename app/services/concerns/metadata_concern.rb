module MetadataConcern
  private

  # 메타데이터에서 제목 추출
  def extract_title_from_metadata(metadata_list)
    return nil if metadata_list.blank?

    first_metadata = metadata_list.first
    content = first_metadata["content"] || first_metadata[:content]
    content.presence
  end

  # 메타데이터 문자열을 파싱
  def parse_metadata_string(metadata_string)
    return [] if metadata_string.blank?

    JSON.parse(metadata_string)
  rescue JSON::ParserError => e
    Rails.logger.error("메타데이터 파싱 오류: #{e.message}")
    raise
  end

  # 게시물에 메타데이터 생성
  def create_post_metadata(post, metadata_list)
    metadata_list.each_with_index do |metadata, index|
      content = metadata["content"] || metadata[:content]
      is_public = !!metadata["isPublic"]
      has_link = !!metadata["hasLink"]

      puts "메타데이터 생성: #{content}, 공개 여부: #{is_public}, 링크 여부: #{has_link}"

      post.post_metadata.create!(
        content: content.to_s,
        is_public: is_public,
        has_link: has_link,
        rank: index
      )
    end
  end
end
