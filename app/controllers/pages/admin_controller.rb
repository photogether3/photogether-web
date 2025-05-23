class Pages::AdminController < PagesController
  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Admin::Sidebar.new
    )
  ) }
end
