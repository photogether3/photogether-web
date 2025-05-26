class Views::Pages::Admin::Users::Posts::Show < Views::Base
  def initialize(post:)
    @post = post
  end

  def view_template
    render Views::Shared::Components::Modal.new(title: "게시물 상세") do
      div(class: "p-6 flex flex-col gap-2 border-t border-base-300 border-dashed") do
        span { "게시물 번호# #{@post[:id]}" }
        span { "사진첩 번호# #{@post&.dig(:collection, :id)} / #{@post&.dig(:collection, :title)}" }
        span { @post[:title] }
        span { @post[:content] }
      end
      div(class: "p-6 flex flex-col gap-2 border-t border-base-300 border-dashed") do
        h2(class: "text-xl") { "메타데이터" }
        table(class: "table table-sm") do
          thead(class: "bg-base-200/50") do
            th { "" }
            th { "컨텐츠" }
            th { "공개여부" }
            th { "링크여부" }
            th { "순번" }
          end
          tbody do
            @post[:metadata_list].each_with_index do |metadatum, i|
              tr do
                td { i+1 }
                td { metadatum[:content] }
                td { metadatum[:is_public] ? "공개" : "비공개" }
                td { metadatum[:has_link] ? "링크" : "일반텍스트" }
                td { metadatum[:rank] }
              end
            end
          end
        end
      end
    end
  end
end
