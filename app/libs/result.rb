# Result 클래스는 서비스 로직의 결과를 표현하는 간단한 값 객체입니다.
# 성공 또는 실패 상태, 관련 데이터, 오류 메시지를 포함합니다.
#
# 사용 예시:
#   result = Result.success(user)          # 성공 결과 생성
#   result = Result.failure("사용자를 찾을 수 없습니다.")  # 실패 결과 생성
#
#   if result.success?
#     # 성공 처리 로직
#     user = result.data
#   else
#     # 실패 처리 로직
#     error_message = result.error_message
#   end
#

class Result
  attr_reader :data, :error_message

  def initialize(success, data = nil, error_message = nil)
    @success = success
    @data = data
    @error_message = error_message
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  # 클래스 메서드 - 성공 결과 생성
  def self.success(data = nil)
    new(true, data)
  end

  # 클래스 메서드 - 실패 결과 생성
  def self.failure(error_message)
    new(false, nil, error_message)
  end
end
