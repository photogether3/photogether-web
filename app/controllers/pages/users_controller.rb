class Pages::UsersController < Pages::SessionController
  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Users::Sidebar.new
    )
  ) }

  def show
    render Pages::Users::Show.new(current_user: current_user)
  end
end
