class Pages::Admin::DashboardController < Pages::AdminController
  def index
    render Pages::Admin::Dashboard::Index.new
  end
end
