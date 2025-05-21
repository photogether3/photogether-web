class Pages::Admin::DashboardController < Pages::AdminController
  def index
    render Dashboard::Index.new
  end
end
