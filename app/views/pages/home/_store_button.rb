class Views::Pages::Home::StoreButton < Views::Base
  def initialize(platform: "ios")
    @platform = platform
    @image_src = platform == "ios"? "/images/landing/section01/appstore.png"
                                  : "/images/landing/section01/googleplay.png"
  end

  def view_template
    a(href: "/qr-code?platform=#{@platform}", data: { turbo_method: "get", turbo_frame: "modal_overlay" }) do
      img(src: @image_src, class: "w-[97px] sm:w-[120px] lg:w-[180px] object-contain")
    end
  end
end
