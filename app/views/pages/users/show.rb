class Views::Pages::Users::Show < Views::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  def view_template
    render Views::Pages::Users::Header.new
  end
end
