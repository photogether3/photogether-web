class Pages::AdminController < PagesController
  include Views::Pages::Admin

  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Admin::Sidebar.new
    )
  ) }
end
