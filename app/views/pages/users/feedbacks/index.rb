class Views::Pages::Users::Feedbacks::Index < Views::Base
  def initialize
  end

  def view_template
    render Views::Pages::Users::Header.new(title: "개선의견")
    div(class: "p-6 border-t border-dashed border-base-300") do
      "개선의견 페이지가 준비중이에요 😢"
    end
  end
end
