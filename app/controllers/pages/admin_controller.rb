class Pages::AdminController < PagesController
  layout "admin"

  def index
    render "pages/admin/dashboard"
  end
end
