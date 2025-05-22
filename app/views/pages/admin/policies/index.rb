class Views::Pages::Admin::Policies::Index < Views::Base
  include Views::Pages::Admin

  def view_template
    render Layout.new do
      div { "약관 관리 페이지" }
    end
  end
end
