class Pages::HomeController < PagesController
  layout -> { Layouts::Application.new }
  def index
    render Pages::Home::Index.new
  end

  def index_mobile
    render Pages::Home::Mobile.new
  end
end
