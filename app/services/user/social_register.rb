class User::SocialRegister
  include UserConcern

  def initialize(params)
    @provider = params[:provider] || nil
    @provider_id = params[:providerId] || nil
    @provider_email = params[:providerEmail] || nil
    @policy_ids = params[:policyIds] || []
  end

  def call
    return Result.failure("프로바이더 타입이 누락되었습니다.", "BAD_REQUEST") if @provider.nil?
    return Result.failure("프로바이더 ID가 누락되었습니다.", "BAD_REQUEST") if @provider_id.nil?
    return Result.failure("이메일이 누락되었습니다.", "BAD_REQUEST") if @provider_email.nil?

    # 필수 약관 검증
    required_policy_validation = validate_required_policies(policy_ids: @policy_ids)
    return required_policy_validation if required_policy_validation.is_a?(Result)

    has_user = User.find_by(
      email_address: @provider_email,
      provider: @provider,
      provider_id: @provider_id
    )
    return Result.failure("이미 가입된 계정입니다.", "BAD_REQUEST") unless has_user.nil?

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

      tokens = Auth::TokenManager.issue_tokens(user)

      Result.success(tokens)
    end
  end
end
