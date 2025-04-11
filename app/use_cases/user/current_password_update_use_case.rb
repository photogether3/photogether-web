class User::CurrentPasswordUpdateUseCase < BaseUseCase
  def initialize(current_user, params)
    @current_user = current_user
    @current_password = params[:currentPassword]
    @new_password = params[:newPassword]
  end

  def call
    # 필수 파라미터 검증
    return failure("현재 비밀번호를 입력해 주세요.") if @current_password.blank?
    return failure("새 비밀번호를 입력해 주세요.") if @new_password.blank?
    return failure("비밀번호는 최소 8자, 최대 50자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함") unless valid_password_format?

    # 현재 사용자 존재 확인
    return failure("로그인이 필요합니다.") unless @current_user

    # 현재 비밀번호 검증
    unless authenticate_current_password
      return failure("현재 비밀번호가 일치하지 않습니다.")
    end

    # 현재 비밀번호와 새 비밀번호가 같은지 확인
    if @current_password == @new_password
      return failure("새 비밀번호는 현재 비밀번호와 달라야 합니다.")
    end

    # 비밀번호 업데이트
    update_password
  end

  private

  def valid_password_format?
    @new_password.to_s.match?(ValidationPatterns::PASSWORD_REGEX)
  end

  def authenticate_current_password
    @current_user.authenticate(@current_password)
  end

  def update_password
    if @current_user.update(
      password: @new_password,
      password_confirmation: @new_password
    )
      success(message: "비밀번호가 성공적으로 변경되었습니다.")
    else
      failure("비밀번호 변경에 실패했습니다: #{@current_user.errors.full_messages.join(', ')}")
    end
  end
end
