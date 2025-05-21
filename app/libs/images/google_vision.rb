class Images::GoogleVision
  def initialize(file)
    @file = file
  end

  # Google Vision API를 사용하여 이미지에서 텍스트를 추출하는 메소드
  def extract_text_lines
    # 이미지 파일 검증 (클래스 메서드 사용)
    validation_result = Shared::ImageValidator.validate_image_file(@file, max_size: 1.megabyte)
    return validation_result if validation_result.failure?

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
