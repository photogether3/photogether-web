class Pages::Admin::PoliciesController < Pages::AdminController
  def index
    policies = Policy.all
    render Policies::Index.new(policies: policies)
  end

  def new
    policy = Policy.new
    render Policies::New.new(policy: policy)
  end

  def create
    puts params.inspect
  end

  def show
    puts params[:id].inspect
    policy = Policy.find(params[:id])
    render Policies::Show.new(policy: policy)
  end

  def edit
  end
end
