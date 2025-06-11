class Views::Pages::Home::GuideSection::MobileFrame < Views::Base
  def view_template
    div(class: "h-full relative") do
      img(src: "/images/landing/section02/item07.png", class: "object-contain")
      div(class: "absolute left-0 top-0 w-full h-full border border-blue-500") do
        render Views::Pages::Home::GuideSection::MobileFrame::Step01.new
      end
    end
  end
end
