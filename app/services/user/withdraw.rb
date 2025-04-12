class User::Withdraw < BaseService
  def initialize(current_user, params)
    @current_user = current_user
    @otp = params[:otp]
  end

  def call
    # 기본 검증
    return failure("로그인이 필요합니다.") unless @current_user
    return failure("OTP는 6자리 숫자여야 합니다.") unless valid_otp_format?

    # OTP 검증
    unless @current_user.verify_otp(@otp)
      return failure("OTP가 유효하지 않습니다.")
    end

    # 계정 삭제 실행
    delete_account
  end

  private

  def valid_otp_format?
    @otp.to_s.match?(ValidationPatterns::OTP_REGEX)
  end

  def delete_account
    # 계정 삭제 전 추가 작업이 필요한 경우 여기에 추가
    # 예: 연관 데이터 백업, 사용자 활동 로그 등

    if @current_user.destroy
      success(message: "계정이 삭제되었습니다.")
    else
      failure("계정 삭제 중 오류가 발생했습니다: #{@current_user.errors.full_messages.join(', ')}")
    end
  end
end
