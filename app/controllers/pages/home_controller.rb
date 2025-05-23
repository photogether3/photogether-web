class Pages::HomeController < PagesController
  def index
    render Pages::Home::Index.new
  end
end
