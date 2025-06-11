class Views::Pages::Home::StoreButton < Views::Base
  def initialize(platform: "ios")
    @platform = platform
    @image_src = platform == "ios"? "/images/landing/section01/appstore.png"
                                  : "/images/landing/section01/googleplay.png"
    @mobile_link = platform == "ios" ? "https://apps.apple.com/kr/app/%ED%8F%AC%ED%86%A0%EA%B2%8C%EB%8D%94/id6745507306"
                                    : "https://play.google.com/apps/test/com.photogether.app/2025051067"
  end

  def view_template
    # 모바일용: 스토어 링크로 바로 연결
    div(class: "lg:hidden") do
      a(href: @mobile_link) do
        img(src: @image_src, class: "w-[97px] sm:w-[120px] object-contain")
      end
    end
    # 데스크탑용: QR 코드 이미지 노출
    div(class: "hidden lg:block") do
      a(href: "/qr-code?platform=#{@platform}", data: { turbo_method: "get", turbo_frame: "modal_overlay" }) do
        img(src: @image_src, class: "w-[180px] object-contain")
      end
    end
  end
end
