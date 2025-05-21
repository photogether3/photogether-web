# app/services/vision_service.rb

class VisionService
  def self.extract_text_lines(file)
    vision = Google::Cloud::Vision.image_annotator
    response = vision.text_detection image: file.tempfile
    annotations = response.responses.first.text_annotations

    return [] if annotations.empty?

    # 전체 텍스트 블록을 줄 단위로 분리
    annotations.first.description.strip.split("\n")
  end
end
