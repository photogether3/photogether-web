class Result
  attr_reader :data, :error_message, :error_code

  def initialize(success, data = nil, error_message = nil, error_code = nil)
    @success = success
    @data = data
    @error_message = error_message
    @error_code = error_code
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  # 클래스 메서드 - 성공 결과 생성
  def self.success(data = nil)
    Rails.logger.info("INFO: Success")
    new(true, data)
  end

  # 클래스 메서드 - 실패 결과 생성 (에러 코드 추가)
  def self.failure(error_message, error_code = nil)
    Rails.logger.warn("WARN: #{error_message}, Code: #{error_code}")
    new(false, nil, error_message, error_code)
  end
end
