class Views::Pages::Home::QrContent < Views::Base
  def initialize(platform: "ios")
    @qr_image_src = platform == "ios"? "/images/landing/ios_qr.png"
                                  : "/images/landing/android_qr.png"
    @store_text = platform == "ios" ? "앱 스토어"
                                    : "구글 플레이 스토어"
    @store_image_src = platform == "ios"? "/images/landing/section01/appstore.png"
                              : "/images/landing/section01/googleplay.png"
  end

  def view_template
    render Views::Shared::Components::Modal.new do
      div(class: "flex flex-col items-center gap-5 p-10 pt-0") do
        div(class: "w-full text-xl flex flex-col gap-5") do
          p(class: "font-bold text-lg") { "#{@store_text} QR코드" }
          p(class: "text-[#C6C6C6]") { "휴대폰 카메라를 이용하여 QR코드를 스캔해주세요." }
        end
        div(class: "rounded-md overflow-hidden") do
          img(src: @qr_image_src, class: "w-[380px] object-contain")
        end
        img(src: @store_image_src, class: "w-[97px] sm:w-[120px] lg:w-[180px] object-contain")
      end
    end
  end
end
