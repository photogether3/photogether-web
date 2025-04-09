require "test_helper"

class User::CurrentPasswordUpdaterTest < ActiveSupport::TestCase
  setup do
    @password = "Password1!"
    @user = User.create!(
      email_address: "password_update_test@example.com",
      password: @password,
      password_confirmation: @password,
      nickname: "비밀번호테스트",
      is_email_verified: true,
      role_id: 1
    )
  end

  test "현재 비밀번호가 없을 경우 실패한다" do
    result = User::CurrentPasswordUpdater.new(@user, {
      newPassword: "NewPassword2@"
    }).call

    assert result.failure?
    assert_equal "현재 비밀번호를 입력해 주세요.", result.error_message
  end

  test "새 비밀번호가 없을 경우 실패한다" do
    result = User::CurrentPasswordUpdater.new(@user, {
      currentPassword: @password
    }).call

    assert result.failure?
    assert_equal "새 비밀번호를 입력해 주세요.", result.error_message
  end

  test "사용자가 없을 경우 실패한다" do
    result = User::CurrentPasswordUpdater.new(nil, {
      currentPassword: @password,
      newPassword: "NewPassword2@"
    }).call

    assert result.failure?
    assert_equal "로그인이 필요합니다.", result.error_message
  end

  test "현재 비밀번호가 일치하지 않을 경우 실패한다" do
    result = User::CurrentPasswordUpdater.new(@user, {
      currentPassword: "WrongPassword1!",
      newPassword: "NewPassword2@"
    }).call

    assert result.failure?
    assert_equal "현재 비밀번호가 일치하지 않습니다.", result.error_message
  end

  test "새 비밀번호가 현재 비밀번호와 같을 경우 실패한다" do
    result = User::CurrentPasswordUpdater.new(@user, {
      currentPassword: @password,
      newPassword: @password
    }).call

    assert result.failure?
    assert_equal "새 비밀번호는 현재 비밀번호와 달라야 합니다.", result.error_message
  end

  test "모든 조건이 충족되면 비밀번호가 성공적으로 업데이트된다" do
    new_password = "NewPassword2@"
    result = User::CurrentPasswordUpdater.new(@user, {
      currentPassword: @password,
      newPassword: new_password
    }).call

    assert result.success?
    assert_equal "비밀번호가 성공적으로 변경되었습니다.", result.data[:message]

    # 비밀번호가 실제로 변경되었는지 확인
    @user.reload
    assert @user.authenticate(new_password), "새 비밀번호로 인증이 가능해야 함"
    assert_not @user.authenticate(@password), "이전 비밀번호로 인증이 불가능해야 함"
  end

  test "유효하지 않은 비밀번호 형식은 실패한다" do
    invalid_password = "weak"
    result = User::CurrentPasswordUpdater.new(@user, {
      currentPassword: @password,
      newPassword: invalid_password
    }).call

    assert result.failure?
  end
end
