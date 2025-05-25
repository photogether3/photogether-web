class Pages::PoliciesController < PagesController
  def show
    kind = params[:kind]
    policy = Policy.where(kind: kind).order(version: :desc).first

    puts policy.inspect

    if policy.nil?
      flash[:alert] = "약관을 찾을 수 없습니다."
      return redirect_to "/", status: :see_other
    end

    render Pages::Policies::Show.new(policy: policy)
  end

  def data_deletion
    render Pages::Policies::DataDeletion.new
  end
end
