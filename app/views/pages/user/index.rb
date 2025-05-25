class Views::Pages::User::Index < Views::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  def view_template
  end
end
