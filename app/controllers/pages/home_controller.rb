class Pages::HomeController < PagesController
  layout -> { Layouts::Application.new }
  def index
    render Pages::Home::Index.new
  end
end
