class Views::Pages::Admin::Categories::Index < Views::Base
  def initialize(categories: [])
    @categories = categories
  end

  def view_template
    div(class: "p-6 flex justify-between items-center") do
      h1(class: "text-2xl") { "카테고리 관리" }
      a(href: "/admin/categories/new", class: "btn btn-soft btn-primary") { "카테고리 추가" }
    end
    div(class: "border-t border-dashed border-base-300") do
      table(class: "table table-sm") do
        thead(class: "bg-base-200/50") do
          th { "" }
          th { "카테고리명" }
          th { "생성일" }
          th { "수정일" }
          th { "" }
        end
        tbody do
          @categories.each_with_index do |category, i|
            tr do
              td { i + 1 }
              td { category[:name] }
              td { date_format(category[:created_at]) }
              td { date_format(category[:updated_at]) }
              td do
                div(class: "flex items-center gap-2") do
                  a(href: "/admin/categories/#{category[:id]}/edit", class: "text-warning") { "수정" }
                  a(
                    href: "/admin/categories/#{category[:id]}",
                    data: {
                      turbo_method: "delete",
                      turbo_confirm: "정말 삭제하시겠어요?"
                    },
                    class: "text-error") { "삭제" }
                end
              end
            end
          end
        end
      end
    end
  end
end
