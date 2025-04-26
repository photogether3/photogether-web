require "test_helper"

class User::RegisterTest < ActiveSupport::TestCase
  setup do
    # 테스트용 약관 생성
    @required_policy1 = Policy.create!(
      title: "필수 약관 1",
      kind: "terms",
      content: "필수 약관 내용",
      version: "1.0",
      is_active: true,
      is_required: true,
      effective_date: Time.current
    )

    @required_policy2 = Policy.create!(
      title: "필수 약관 2",
      kind: "privacy",
      content: "개인정보처리방침 내용",
      version: "1.0",
      is_active: true,
      is_required: true,
      effective_date: Time.current
    )

    @optional_policy = Policy.create!(
      title: "선택 약관",
      kind: "marketing",
      content: "마케팅 정보 활용 동의",
      version: "1.0",
      is_active: true,
      is_required: false,
      effective_date: Time.current
    )
  end

  test "회원가입 성공 시 유저를 반환한다" do
    params = {
      email: "new_user@example.com",
      password: "testPassword1!",
      policy_ids: [ @required_policy1.id, @required_policy2.id, @optional_policy.id ]
    }

    result = User::Register.new(params).call

    assert result.success?
    user = result.data
    assert user.is_a?(User)
    assert_equal "new_user@example.com", user.email_address
    assert user.nickname.present?
    assert_equal 2, user.collections.count

    uncategorized = user.collections.find_by(type: "UNCATEGORIZED")
    trash = user.collections.find_by(type: "TRASH")
    assert uncategorized
    assert trash

    # 약관 동의 정보 확인
    policy_acceptances = PolicyAcceptance.where(user_id: user.id)
    assert_equal 3, policy_acceptances.count

    # 모든 약관에 동의했는지 확인
    agreed_policy_ids = policy_acceptances.pluck(:policy_id)
    assert_includes agreed_policy_ids, @required_policy1.id
    assert_includes agreed_policy_ids, @required_policy2.id
    assert_includes agreed_policy_ids, @optional_policy.id
  end

  test "필수 약관에 모두 동의하면 선택 약관 없이도 회원가입 성공" do
    params = {
      email: "new_user2@example.com",
      password: "testPassword1!",
      policy_ids: [ @required_policy1.id, @required_policy2.id ] # 선택 약관 제외
    }

    result = User::Register.new(params).call

    assert result.success?
    user = result.data

    # 약관 동의 정보 확인
    policy_acceptances = PolicyAcceptance.where(user_id: user.id)
    assert_equal 2, policy_acceptances.count

    # 필수 약관만 동의했는지 확인
    agreed_policy_ids = policy_acceptances.pluck(:policy_id)
    assert_includes agreed_policy_ids, @required_policy1.id
    assert_includes agreed_policy_ids, @required_policy2.id
    refute_includes agreed_policy_ids, @optional_policy.id
  end

  test "필수 약관에 동의하지 않으면 회원가입 실패" do
    # 필수 약관 1만 동의
    params = {
      email: "new_user3@example.com",
      password: "testPassword1!",
      policy_ids: [ @required_policy1.id, @optional_policy.id ] # 필수 약관 2 누락
    }

    result = User::Register.new(params).call

    assert result.failure?
    assert_match /필수 약관에 모두 동의해야 합니다/, result.error_message
    assert_match /#{@required_policy2.title}/, result.error_message
  end

  test "약관 동의 없이 회원가입 시도하면 실패" do
    params = {
      email: "new_user4@example.com",
      password: "testPassword1!",
      policy_ids: [] # 약관 동의 없음
    }

    result = User::Register.new(params).call

    assert result.failure?
    assert_match /필수 약관에 모두 동의해야 합니다/, result.error_message
    assert_match /#{@required_policy1.title}/, result.error_message
    assert_match /#{@required_policy2.title}/, result.error_message
  end

  test "이메일 형식이 유효하지 않으면 실패한다" do
    params = {
      email: "invalid_email",
      password: "testPassword1!",
      policy_ids: [ @required_policy1.id, @required_policy2.id ]
    }

    result = User::Register.new(params).call

    assert result.failure?
    assert_equal "유효한 이메일을 입력해 주세요.", result.error_message
  end

  test "비밀번호가 없으면 실패한다" do
    params = {
      email: "new_user@example.com",
      password: "",
      policy_ids: [ @required_policy1.id, @required_policy2.id ]
    }

    result = User::Register.new(params).call

    assert result.failure?
    assert_equal "비밀번호를 입력해 주세요.", result.error_message
  end
end
