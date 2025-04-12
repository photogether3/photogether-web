require "test_helper"

class Auth::TokenManagerTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "token_test@example.com",
      password: "Password1!",
      is_email_verified: true,
      nickname: "토큰테스트",
      role_id: 1
    )
  end

  describe ".issue_tokens" do
    test "access_token과 refresh_token을 발급하고 DB에 저장한다" do
      tokens = Auth::TokenManager.issue_tokens(@user)

      assert tokens[:access_token].present?
      assert tokens[:refresh_token].present?
      assert tokens[:expires_in].present?

      refresh = RefreshToken.find_by(user_id: @user.id)
      assert refresh, "RefreshToken 레코드가 저장되어야 합니다."
      assert_equal tokens[:refresh_token], refresh.refresh_token
    end
  end

  describe ".generate_tokens" do
    test "access_token과 refresh_token을 발급하지만 DB에는 저장하지 않는다" do
      tokens = Auth::TokenManager.generate_tokens(@user.id)

      assert tokens[:access_token].present?
      assert tokens[:refresh_token].present?
      assert tokens[:expires_in].present?

      # DB에는 저장되지 않아야 함
      refute RefreshToken.find_by(refresh_token: tokens[:refresh_token])
    end
  end

  describe ".decode_token" do
    test "발급된 access_token을 복호화하여 payload를 반환한다" do
      tokens = Auth::TokenManager.generate_tokens(@user.id)
      decoded = Auth::TokenManager.decode_token(tokens[:access_token])

      assert decoded.present?
      assert_equal @user.id.to_s, decoded["sub"]
    end

    test "유효하지 않은 토큰은 nil을 반환한다" do
      invalid_token = "this.is.not.valid"
      decoded = Auth::TokenManager.decode_token(invalid_token)

      assert_nil decoded
    end
  end
end
