require "test_helper"

class Auth::OtpTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "otp_user@example.com",
      password: "Password1!",
      is_email_verified: false,
      nickname: "OTPUser",
      role_id: 1
    )

    ActionMailer::Base.deliveries.clear
  end

  describe "#generate" do
    test "정상적으로 OTP를 생성하고 메일을 보낸다" do
      result = Auth::Otp.new(email: @user.email_address).generate(with_otp: true)

      assert result.success?
      assert_match(/\A\d{6}\z/, result.data)
      assert_equal 1, ActionMailer::Base.deliveries.size
    end

    test "이메일 형식이 잘못되면 실패한다" do
      result = Auth::Otp.new(email: "invalid_email").generate
      assert result.failure?
      assert_equal "유효한 이메일을 입력해 주세요.", result.error_message
    end

    test "존재하지 않는 사용자면 실패한다" do
      result = Auth::Otp.new(email: "ghost@example.com").generate
      assert result.failure?
      assert_equal "사용자를 찾을 수 없습니다.", result.error_message
    end
  end

  describe "#verify" do
    setup do
      @otp = "123456"
      @user.update_otp(@otp)
    end

    test "OTP가 일치하면 성공한다" do
      result = Auth::Otp.new(email: @user.email_address, otp: @otp).verify
      assert result.success?
    end

    test "OTP가 틀리면 실패한다" do
      result = Auth::Otp.new(email: @user.email_address, otp: "000000").verify
      assert result.failure?
      assert_equal "OTP가 일치하지 않습니다.", result.error_message
    end

    test "OTP 형식이 유효하지 않으면 실패한다" do
      result = Auth::Otp.new(email: @user.email_address, otp: "abc123").verify
      assert result.failure?
      assert_equal "OTP는 6자리 숫자여야 합니다.", result.error_message
    end

    test "존재하지 않는 사용자면 실패한다" do
      result = Auth::Otp.new(email: "ghost@example.com", otp: "123456").verify
      assert result.failure?
      assert_equal "사용자를 찾을 수 없습니다.", result.error_message
    end
  end

  describe "#verify with_tokens option" do
    setup do
      @otp = "654321"
      @user.update_otp(@otp)
    end

    test "정상적인 OTP 입력 시 토큰 발급과 이메일 인증 처리" do
      result = Auth::Otp.new(email: @user.email_address, otp: @otp).verify(with_tokens: true)

      assert result.success?
      assert result.data[:access_token].present? || result.data["access_token"].present?
      assert result.data[:refresh_token].present? || result.data["refresh_token"].present?
      assert result.data[:expires_in].present? || result.data["expires_in"].present?

      @user.reload
      assert @user.is_email_verified
      assert_nil @user.otp
      assert_nil @user.otp_expiry_date
    end

    test "OTP가 틀리면 with_tokens 옵션과 상관없이 실패한다" do
      result = Auth::Otp.new(email: @user.email_address, otp: "111111").verify(with_tokens: true)

      assert result.failure?
      assert_equal "OTP가 일치하지 않습니다.", result.error_message
    end
  end
end
