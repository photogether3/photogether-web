class Views::Pages::Users::Header < Views::Base
  def initialize(title: "내 정보")
    @title = title
  end

  def view_template
    div(class: "p-6 flex justify-between items-center") do
      h2(class: "text-xl") { @title }
      a(
        href: "/session/logout",
        class: "btn btn-soft btn-error",
        data: {
          # turbo_prefetch: "false",
          turbo_method: "delete",
          turbo_confirm: "로그아웃 하시겠어요?"
        }) { "로그아웃" }
    end
  end
end
