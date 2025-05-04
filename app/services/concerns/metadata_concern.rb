module MetadataConcern
  MAX_METADATA_LENGTH = 100

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

      if content.blank?
        Rails.logger.warn("메타데이터 내용 없음(#{index+1}번째): #{content}")
        raise ArgumentError, "메타데이터 텍스트는 필수값입니다. [#{index+1}]번째 항목"
      end

      if content.to_s.length > MAX_METADATA_LENGTH
        Rails.logger.warn("메타데이터 길이 초과(#{index+1}번째): #{content.to_s.length}자")
        # 두 가지 방법 중 선택

        # 방법 1: 에러 발생시키기
        raise ArgumentError, "메타데이터 텍스트는 #{MAX_METADATA_LENGTH}자를 초과할 수 없습니다. [#{index+1}]번째 항목"

        # 방법 2: 자동으로 자르기 (주석 처리된 대안)
        # content = content.to_s[0...MAX_METADATA_LENGTH]
        # Rails.logger.info("메타데이터 길이 초과로 자동 잘림: #{content}")
      end

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
