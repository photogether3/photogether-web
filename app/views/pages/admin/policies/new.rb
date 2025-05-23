class Views::Pages::Admin::Policies::New < Views::Base
  include Views::Pages::Admin

  def initialize(policy:)
    @policy = policy
  end

  def view_template
    div(class: "flex items-center gap-2 p-6") do
      a(href: "/admin/policies",
        class: "text-xl") do
        raw(<<~SVG.html_safe)
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
        SVG
      end
      h1(class: "text-2xl") { "약관 등록" }
    end

    render Policies::Form.new(policy: @policy)
  end
end
