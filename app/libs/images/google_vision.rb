class Images::GoogleVision
  def initialize(file)
    @file = file
  end

  # Google Vision API를 사용하여 이미지에서 텍스트를 추출하는 메소드
  # @param file [File] 이미지 파일
  # @return [Array<String>] 추출된 텍스트 줄 배열
  def extract_text_lines
    return Result.failure("파일은 필수값 입니다.") if @file.blank?

    vision = Google::Cloud::Vision.image_annotator
    response = vision.text_detection image: @file.tempfile
    annotations = response.responses.first.text_annotations

    return Result.success(lines: []) if annotations.empty?

    # 전체 텍스트 블록을 줄 단위로 분리
    lines = annotations.first.description.strip.split("\n")
    Result.success(lines: lines)
  end
end
