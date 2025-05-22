class Views::Pages::Admin::Users::Index < Views::Base
  include Views::Pages::Admin

  def view_template
    render Layout.new do
      div { "회원 관리 페이지" }
    end
  end
end
