class User::Register
  include UserConcern

  def initialize(params)
    @email     = params[:email] || ""
    @password  = params[:password] || ""
    @policy_ids = params[:policyIds] || []
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

    # 이메일 + provider 중복 검사
    existing_user = User.find_by(email_address: @email, provider: "email")
    if existing_user
      return Result.failure("해당 이메일로 이미 가입된 계정이 있습니다.", "EMAIL_EXISTS")
    end

    # 필수 약관 검증
    required_policy_validation = validate_required_policies(policy_ids: @policy_ids)
    return required_policy_validation if required_policy_validation.is_a?(Result)

    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: @email,
        password: @password,
        password_confirmation: @password,
        provider: "email",
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
end
