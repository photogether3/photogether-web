class ApplicationJob < ActiveJob::Base
  # 데드락이 발생한 작업을 자동으로 재시도합니다
  # retry_on ActiveRecord::Deadlocked

  # 기본 레코드가 더 이상 사용 가능하지 않은 경우 대부분의 작업은 무시해도 안전합니다
  # discard_on ActiveJob::DeserializationError
end
