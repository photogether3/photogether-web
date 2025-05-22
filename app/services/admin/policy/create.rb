class Admin::Policy::Create
  def initialize(params)
    # params[:policy] 해시에서 값 추출
    policy_params = params[:policy]

    @title = policy_params[:title]
    @content = policy_params[:content]
    @kind = policy_params[:kind]
    @is_required = policy_params[:is_required] == "true"
    @is_active = policy_params[:is_active] == "true"
    @version = policy_params[:version]
    @effective_date = policy_params[:effective_date].presence || Date.current.to_s

    puts "제목: #{@title}"
    puts "내용: #{@content}"
    puts "종류: #{@kind}"
    puts "필수여부: #{@is_required}"
    puts "활성여부: #{@is_active}"
    puts "버전: #{@version}"
    puts "정책효력일자: #{@effective_date}"
  end

  def call
    return Result.failure("제목을 입력해 주세요") unless @title
    return Result.failure("내용을 입력해 주세요") unless @content
    return Result.failure("종류를 선택해 주세요") unless @kind

    # 새 Policy 객체 생성 및 저장
    policy = Policy.new(
      title: @title,
      content: @content,
      kind: @kind,
      is_required: @is_required,
      is_active: @is_active,
      version: @version,
      effective_date: @effective_date  # effective_date 추가
    )

    if policy.save
      Result.success(policy)
    else
      Result.failure(policy.errors.full_messages.join(", "))
    end
  end
end
