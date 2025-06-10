class Views::Pages::Home::HorizontalScrollBox < Views::Base
  def initialize(tw_class: "relative flex gap-[16px] lg:gap-[22px]")
    @tw_class = tw_class
  end

  def view_template
    div(class: "relative", data: { controller: "dynamic-scroll-gradient" }) do
      div(
        class: "block lg:hidden absolute top-0 left-0 w-[21px] h-full bg-gradient-to-r from-base-100/80 to-base-100/5",
        data: { "dynamic-scroll-gradient-target": "leftGradient" })
      div(
        class: "block lg:hidden absolute top-0 right-0 w-[21px] h-full bg-gradient-to-r from-base-100/5 to-base-100/80",
        data: { "dynamic-scroll-gradient-target": "rightGradient" })

      div(class: "overflow-auto hidden-scrollbar pl-4 lg:p-none #{@tw_class}",
          data: { "dynamic-scroll-gradient-target": "scrollBox" }) do
        yield if block_given?
      end
    end
  end
end
