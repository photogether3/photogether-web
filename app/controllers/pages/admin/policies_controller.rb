class Pages::Admin::PoliciesController < Pages::AdminController
  def index
    render Policies::Index.new
  end

  def new
  end
end
