class Views::Pages::Admin::Categories::Edit < Views::Base
  def initialize(category:)
    @category = category
  end

  def view_template
    div(class: "p-6 flex items-center gap-2") do
      a(href: "/admin/categories",
        class: "text-xl") do
        raw(<<~SVG.html_safe)
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
        SVG
      end
      h2(class: "text-2xl") { "카테고리 추가" }
    end
    render Views::Pages::Admin::Categories::Form.new(category: @category, is_edit: true)
  end
end
