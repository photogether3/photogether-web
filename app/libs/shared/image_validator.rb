class Shared::ImageValidator
  # 클래스 메서드로 변경
  def self.validate_image_file(file, options = {})

    puts "validate_image_file called with file: #{file.inspect}"

    # 파일이 없는 경우
    return Result.failure("파일은 필수값 입니다.", "FILE_REQUIRED") if file.blank?

    # 유효한 파일 객체인지 확인
    unless file.respond_to?(:content_type)
      Rails.logger.warn "유효하지 않은 파일 형식: #{file.inspect}"
      return Result.failure("올바른 이미지 파일이 아닙니다.", "INVALID_FILE_OBJECT")
    end

    # 파일이 비어있는 경우 확인
    if file.size == 0
      Rails.logger.warn "빈 이미지 파일: #{file.inspect}"
      return Result.failure("이미지 파일이 비어있습니다.", "EMPTY_FILE")
    end

    # 파일 형식 확인 (이미지 파일인지)
    valid_mime_types = [ "image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp" ]
    unless valid_mime_types.include?(file.content_type)
      Rails.logger.warn "지원하지 않는 이미지 형식: #{file.content_type}"
      return Result.failure("지원하지 않는 이미지 파일 형식입니다.", "INVALID_IMAGE_FORMAT")
    end

    # 파일 크기 제한
    max_size = options[:max_size] || 3.megabytes
    if file.size > max_size
      Rails.logger.warn "이미지 크기 초과: #{file.size} bytes"
      return Result.failure("이미지 파일 크기는 #{(max_size / 3.megabyte).to_i}MB 이하여야 합니다.", "FILE_TOO_LARGE")
    end

    # 모든 검증 통과
    Result.success
  end
end
