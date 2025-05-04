class Images::GoogleVision
  def initialize(file)
    @file = file
  end

  # Google Vision API를 사용하여 이미지에서 텍스트를 추출하는 메소드
  # @param file [File] 이미지 파일
  # @return [Array<String>] 추출된 텍스트 줄 배열
  def extract_text_lines
    return Result.failure("파일은 필수값 입니다.", "FILE_REQUIRED") if @file.blank?

    # 파일이 비어있는 경우 확인
    if @file.size == 0
      return Result.failure("이미지 파일이 비어있습니다.", "EMPTY_FILE")
    end

    # 파일 형식 확인 (이미지 파일인지)
    valid_mime_types = [ "image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp" ]
    unless valid_mime_types.include?(@file.content_type)
      return Result.failure("올바른 이미지 파일 형식이 아닙니다.", "INVALID_IMAGE_FORMAT")
    end

    begin
      vision = Google::Cloud::Vision.image_annotator
      response = vision.text_detection image: @file.tempfile
      annotations = response.responses.first.text_annotations

      return Result.failure("추출된 텍스트가 없습니다.", "TEXT_EXTRACTION_NULL") if annotations.empty?

      # 전체 텍스트 블록을 줄 단위로 분리
      lines = annotations.first.description.strip.split("\n")
      Result.success(lines: lines)
    rescue => e
      Rails.logger.error("Google Vision API 오류: #{e.message}")
      Result.failure("이미지 텍스트 추출 중 오류가 발생했습니다.", "TEXT_EXTRACTION_ERROR")
    end
  end
end
