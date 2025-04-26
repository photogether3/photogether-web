class User::Register
  def initialize(params)
    @email     = params[:email] || ""
    @password  = params[:password] || ""
    @policy_ids = params[:policy_ids] || []
    @with_user = true # 프로세스가 끝날 때 user 데이터를 반환할지 여부
  end

  # 메서드 체이닝을 통해 반환데이터에 user를 포함하지 않습니다.
  def without_user
    @with_user = false
    self
  end

  def call
    return Result.failure("유효한 이메일을 입력해 주세요.") unless valid_email?
    return Result.failure("비밀번호를 입력해 주세요.") if @password.blank?
    return Result.failure("비밀번호는 최소 8자, 최대 50자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함") unless ValidationPatterns::PASSWORD_REGEX.match?(@password)

    # 필수 약관 검증
    required_policy_validation = validate_required_policies
    return required_policy_validation if required_policy_validation.is_a?(Result)

    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: @email,
        password: @password,
        password_confirmation: @password,
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

      return Result.success(user) if @with_user

      Result.success
    end
  end

  private

    # 이메일 유효성 검증
    def valid_email?
      @email.match?(ValidationPatterns::EMAIL_REGEX)
    end

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
