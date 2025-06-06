class User::SocialRegister
  include UserConcern

  def initialize(params)
    @provider = params[:provider] || nil
    @provider_id = params[:providerId] || nil
    @provider_email = params[:providerEmail] || nil
    @policy_ids = params[:policyIds] || []
  end

  def call
    return Result.failure("프로바이더 타입이 누락되었습니다.", "MISSING_PROVIDER") if @provider.blank?
    return Result.failure("프로바이더 ID가 누락되었습니다.", "MISSING_PROVIDER_ID") if @provider_id.blank?
    return Result.failure("이메일이 누락되었습니다.", "MISSING_EMAIL") if @provider_email.blank?
    
    # 이메일 + provider 중복 검사 (같은 프로바이더로 가입된 사용자가 있는지)
    existing_user = User.find_by(email_address: @provider_email, provider: @provider)
    if existing_user
      return Result.failure("이미 해당 소셜 계정으로 가입한 사용자가 있습니다.", "USER_EXISTS")
    end

    # 필수 약관 검증
    required_policy_validation = validate_required_policies(policy_ids: @policy_ids)
    return required_policy_validation if required_policy_validation.is_a?(Result)

    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: @provider_email,
        provider: @provider,
        provider_id: @provider_id,
        role_id: 1,
        nickname: generate_random_nickname,
        is_email_verified: true # 소셜 로그인은 이메일 인증 불필요
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH", title: "휴지통" }
      ])

      # 동의한 약관 처리
      save_policy_acceptances(user)

      puts "회원가입 성공: #{user.inspect}"

      tokens = Auth::TokenManager.issue_tokens(user)

      Result.success(tokens)
    end
  end
end
