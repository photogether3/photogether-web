class Admin::Policy::Update
  def initialize(policy:, params:)
    # params[:policy] 해시에서 값 추출
    policy_params = params[:policy]

    @policy = policy
    @title = policy_params[:title]
    @content = policy_params[:content]
    @kind = policy_params[:kind]
    @is_required = policy_params[:is_required] == "true"
    @is_active = policy_params[:is_active] == "true"
    @version = policy_params[:version]
    @effective_date = policy_params[:effective_date].presence || Date.current.to_s
  end

  def call
    return Result.failure("약관을 찾을 수 없습니다.") unless @policy.present?
    return Result.failure("제목을 입력해 주세요") unless @title
    return Result.failure("내용을 입력해 주세요") unless @content
    return Result.failure("종류를 선택해 주세요") unless @kind

    # 기존 Policy 객체 업데이트
    @policy.title = @title
    @policy.content = @content
    @policy.kind = @kind
    @policy.is_required = @is_required
    @policy.is_active = @is_active
    @policy.version = @version
    @policy.effective_date = @effective_date

    if @policy.save
      Result.success(@policy)
    else
      Result.failure(@policy.errors.full_messages.join(", "))
    end
  end
end
