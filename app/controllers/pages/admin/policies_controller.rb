class Pages::Admin::PoliciesController < Pages::AdminController
  def index
    policies = Policy.all
    render Policies::Index.new(policies: policies)
  end

  def new
  end
end
