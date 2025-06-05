class Pages::NotYetController < PagesController
  layout false

  def index
    render Views::Shared::Components::NotYet.new
  end
end
