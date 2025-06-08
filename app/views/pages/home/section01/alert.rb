class Views::Pages::Home::Section01::Alert < Views::Base
  def initialize(tw_class: "")
    @tw_class = tw_class
  end

  def view_template
    div(class: "#{@tw_class}
        border border-primary p-[9px] sm:p-3 lg:p-8
        rounded-sm sm:rounded-lg lg:rounded-xl
      bg-[#1B1D21CC]/80 backdrop-blur-md") do
      div(class: "w-full flex justify-end") do
        raw(<<~SVG.html_safe)
          <svg class="w-[5px] sm:w-[14px] lg:w-[20px]" viewBox="0 0 26 25" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M19.598 4.77711C19.9154 4.45973 20.43 4.45971 20.7474 4.77708C21.0648 5.09445 21.0648 5.60902 20.7474 5.92641L14.0097 12.6645L20.7514 19.4066C21.0687 19.7239 21.0687 20.2385 20.7513 20.5559C20.4339 20.8733 19.9194 20.8732 19.602 20.5559L12.8604 13.8139L6.11883 20.5559C5.80146 20.8732 5.28688 20.8733 4.9695 20.5559C4.65211 20.2385 4.65209 19.7239 4.96946 19.4066L11.7111 12.6645L4.97343 5.92641C4.65606 5.60902 4.65608 5.09445 4.97346 4.77708C5.29085 4.45971 5.80542 4.45973 6.12279 4.77711L12.8604 11.5151L19.598 4.77711Z" fill="white"/>
          </svg>
        SVG
      end
      div(class: "flex flex-col items-center gap-1 sm:gap-2 lg:gap-3") do
        img(src: "/images/landing/section01/item05.png", class: "w-[28px] sm:w-[50px] lg:w-[101px]")
        strong(class: "text-[6px] sm:text-[8px] lg:text-xl") { "택스트를 추출 합니다." }
        div(class: "text-center text-[5px] sm:text-[8px] lg:text-lg text-[#D8D8D8]") do
          p { "업로드하신 이미지에서 텍스트를" }
          p { "자동으로 추출합니다." }
        end
        div(class: "mt-1 sm:mt-4 lg:mt-5
            flex justify-between
            gap-1 sm:gap-2 lg:gap-4 w-full") do
          button(class: "pg-btn btn-neutral border-neutral-content flex-1 text-[5px] sm:text-[8px] lg:text-sm") { "취소" }
          button(class: "pg-btn btn-primary flex-1 text-[5px] sm:text-[8px] lg:text-sm") { "확인" }
        end
      end
    end
  end
end
