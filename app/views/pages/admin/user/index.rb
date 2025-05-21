class Views::Pages::Admin::User::Index < Views::Base
  include Views::Pages::Admin

  def initialize
  end

  def view_template
    render Layout.new do
      div { "회원 관리 페이지" }
    end
  end
end
