class Pages::Admin::PoliciesController < Pages::AdminController
  def index
    policies = Policy.order(kind: :asc, version: :desc)
    render Policies::Index.new(policies: policies)
  end

  def new
    policy_attributes = flash[:policy] || {}
    alert = flash[:alert] || nil

    policy = if policy_attributes.present?
      Policy.new(policy_attributes)
    else
      Policy.new(
        is_active: true,
        is_required: true,
        version: 1.0
      )
    end

    render Policies::New.new(policy: policy, alert: alert)
  end

  def create
    result = Admin::Policy::Create.new(params).call

    if result.success?
      redirect_to admin_policies_path, alert: "약관이 성공적으로 등록되었습니다."
    else
      flash[:alert] = result.error_message
      flash[:policy] = policy_params.to_h
      redirect_to admin_policies_new_path
    end
  end

  def show
    puts params[:id].inspect
    policy = Policy.find(params[:id])
    render Policies::Show.new(policy: policy)
  end

  def edit
    alert = flash[:alert] || nil
    policy = Policy.find(params[:id])
    render Policies::Edit.new(policy: policy, alert: alert)
  end

  def update
    policy = Policy.find(params[:id])
    puts policy.inspect
    result = Admin::Policy::Update.new(policy: policy, params: params).call

    if result.success?
      redirect_to "/admin/policies", notice: "약관이 성공적으로 수정되었습니다."
    else
      flash[:alert] = result.error_message
      flash[:policy] = policy_params.to_h
      redirect_to "/admin/policies/#{policy.id}/edit"
    end
  end

  private

  def policy_params
    params.require(:policy).permit(:title, :content, :kind, :is_active, :is_required, :version, :effective_date)
  end
end
