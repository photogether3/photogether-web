class Views::Pages::Admin::Categories::Form < Views::Base
  def initialize(category: nil, is_edit: false)
    @category = category
    @is_edit = is_edit
  end

  def view_template
    form(
      action: @is_edit ? "/admin/categories/#{@category[:id]}" : "/admin/categories",
      method: @is_edit ? "put" : "post") do
      div(class: "p-6 border-y border-dashed border-base-300") do
        fieldset(class: "fieldset") do
          legend(class: "fieldset-legend text-sm") { "카테고리명" }
          input(
            type: "text",
            name: "category[name]",
            value: @category[:name] || "",
            placeholder: "카테고리 이름을 작성해 주세요.",
            class: "input")
        end
      end
      div(class: "p-6") do
        button(class: "btn btn-soft btn-primary") {
          @is_edit ? "수정" : "추가"
        }
      end
    end
  end
end
