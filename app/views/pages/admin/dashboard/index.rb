class Views::Pages::Admin::Dashboard::Index < Views::Base
  include Views::Pages::Admin

  def initialize
  end

  def view_template
    render Layout.new do
      div { "대시보드 페이지" }
    end
  end
end
