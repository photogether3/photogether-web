require "test_helper"

class Auth::TokenRefresherTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "refresh_user@example.com",
      password: "Password1!",
      is_email_verified: true,
      nickname: "리프레시유저",
      role_id: 1
    )
  end

  describe "#call" do
    test "유효한 리프레시 토큰으로 토큰 재발급 성공" do
      # 초기 토큰 발급
      issued_tokens = Auth::TokenManager.issue_tokens(@user)
      refresh_token = issued_tokens[:refresh_token]

      # 실제 DB에 저장된 리프레시 토큰 확인
      assert RefreshToken.exists?(refresh_token: refresh_token)

      result = Auth::TokenRefresher.new(refresh_token).call

      assert result.success?
      assert result.data[:access_token].present?
      assert result.data[:refresh_token].present?
      assert result.data[:expires_in].present?
    end

    test "리프레시 토큰이 비어있으면 실패한다" do
      result = Auth::TokenRefresher.new(nil).call

      assert result.failure?
      assert_equal "리프레시 토큰이 없습니다.", result.error_message
    end

    test "DB에 존재하지 않는 리프레시 토큰이면 실패한다" do
      result = Auth::TokenRefresher.new("non_existing_token").call

      assert result.failure?
      assert_equal "리프레시 토큰이 유효하지 않습니다.", result.error_message
    end

    test "리프레시 토큰이 만료되었으면 실패한다" do
      expired_token = "expired-123456"
      RefreshToken.create!(
        user: @user,
        refresh_token: expired_token,
        expiry_date: 1.hour.ago,
        last_refreshing_date: Time.current
      )

      result = Auth::TokenRefresher.new(expired_token).call

      assert result.failure?
      assert_equal "리프레시 토큰이 유효하지 않습니다.", result.error_message
    end
  end
end
