class Views::Pages::Home::Section03::Review < Views::Base
  def initialize(reviewer: "리뷰어", rating: 5, content: "컨텐츠")
    @reviewer = reviewer
    @rating = rating
    @content = content
  end

  def view_template
    div(class: "border border-primary rounded-[20px] p-[16px] lg:p-[24px] min-w-[200px] w-[200px] lg:w-[323px]") do
      div(class: "flex items-center gap-[12px]") do
        div do
          img(src: "/images/landing/section03/item02.png", class: "w-[32px] lg:w-[60px] object-contain")
        end
        div do
          h2(class: "text-[14px] lg:text-xl") { @reviewer }
          div(class: "flex items-center gap-1 lg:gap-2") do
            @rating.times do
              raw(<<~SVG.html_safe)
                <svg class="w-[12px] lg:w-[20px]" viewBox="0 0 20 19" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M10 0L12.2451 6.90983H19.5106L13.6327 11.1803L15.8779 18.0902L10 13.8197L4.12215 18.0902L6.36729 11.1803L0.489435 6.90983H7.75486L10 0Z" fill="#00AC69"/>
                </svg>
              SVG
            end
          end
        end
      end
      # 4줄로 조정하는 예시
      div(class: "text-[#C6C6C6] text-[10px] lg:text-sm mt-[12px] tracking-normal leading-[150%] overflow-hidden") do
        p(class: "line-clamp-6 overflow-hidden text-ellipsis") { @content }
      end
    end
  end
end
