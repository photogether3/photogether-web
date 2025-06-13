class Views::Pages::Home::GuideSection::MobileFrame < Views::Base
  def view_template
    div(class: "relative
                w-[180px] h-[352px]
                lg:w-[360px] lg:h-[728px]") do
      div(class: "absolute inset-0 p-1") do
        div(class: "overflow-hidden h-full bg-base-100 mobile-frame-shadow
            rounded-2xl
            md:rounded-[50px]") do
          div(class: "px-2 md:px-4") do
            div(class: "h-6 md:h-16")
            div(data: { "mobile-guide-target": "mobileFrame" }) do
              render Views::Pages::Home::GuideSection::MobileFrame::Step01.new
              render Views::Pages::Home::GuideSection::MobileFrame::Step02.new
              render Views::Pages::Home::GuideSection::MobileFrame::Step03.new
              render Views::Pages::Home::GuideSection::MobileFrame::Step04.new
            end
          end
        end
      end
      img(src: "/images/landing/section02/item07.png", class: "absolute inset-0 w-full h-full")
    end
  end
end
