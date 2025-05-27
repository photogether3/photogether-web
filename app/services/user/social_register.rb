class User::SocialRegister
  def initialize(
    provider: nil,
    provider_id: nil,
    provider_email: nil
  )
    @provider = provider
    @provider_id = provider_id
    @provider_email = provider_email
    @policy_ids = params[:policyIds] || []
  end

  def call
    return Result.failure("프로바이더 타입이 누락되었습니다.", "BAD_REQUEST") if @provider.nil?
    return Result.failure("프로바이더 ID가 누락되었습니다.", "BAD_REQUEST") if @provider_id.nil?
    return Result.failure("이메일이 누락되었습니다.", "BAD_REQUEST") if @provider_email.nil?

    # 필수 약관 검증
    required_policy_validation = validate_required_policies
    return required_policy_validation if required_policy_validation.is_a?(Result)

    ActiveRecord::Base.transaction do
      user = User.create!(
        provider: @provider,
        provider_id: @provider_id,
        email_address: @provider_email,
        role_id: 1,
        nickname: generate_random_nickname,
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH", title: "휴지통" }
      ])

      # 동의한 약관 처리
      save_policy_acceptances(user)

      puts "회원가입 성공: #{user.inspect}"

      Result.success(user)
    end
  end

  private

    # 랜덤한 닉네임을 생성하는 메서드
    def generate_random_nickname
      prefixes = %w[
        멋진 든든한 귀여운 강력한 재빠른
        화려한 용감한 현명한 활기찬 유쾌한
      ]

      suffixes = %w[
        고래밥 사자 호랑이 독수리 고양이
        강아지 여우 팬더 토끼 공룡
      ]

      random_prefix = prefixes.sample
      random_suffix = suffixes.sample

      "#{random_prefix} #{random_suffix}"
    end

    # 필수 약관 검증 메서드
    def validate_required_policies
      # 활성화된 필수 약관 ID 목록 조회
      required_policy_ids = Policy.where(is_active: true, is_required: true).pluck(:id)

      # 사용자가 동의한 약관 ID 목록
      user_agreed_policy_ids = @policy_ids.map(&:to_i)

      # 필수 약관 중 사용자가 동의하지 않은 것이 있는지 확인
      missing_required_policies = required_policy_ids - user_agreed_policy_ids

      if missing_required_policies.any?
        missing_policies = Policy.where(id: missing_required_policies).pluck(:title).join(", ")
        return Result.failure("필수 약관에 모두 동의해야 합니다. 누락된 약관: #{missing_policies}")
      end

      true
    end

    # 동의한 약관 저장 메서드
    def save_policy_acceptances(user)
      return if @policy_ids.empty?

      # 현재 시간
      current_time = Time.current

      # 약관 동의 데이터 생성
      policy_acceptances = @policy_ids.map do |policy_id|
        {
          user_id: user.id,
          policy_id: policy_id,
          accepted_at: current_time
        }
      end

      # 일괄 생성
      PolicyAcceptance.insert_all(policy_acceptances)
    end
end
