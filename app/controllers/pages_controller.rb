class PagesController < ActionController::Base
  include Views

  helper ViteHelper

  # 최신 브라우저만 접근을 허용합니다.
  # 이 설정은 다음 기능들을 지원하는 최신 브라우저만 허용합니다:
  # - webp 이미지 포맷 지원
  # - 웹 푸시 알림(Web Push Notifications)
  # - 브라우저 뱃지 API
  # - JavaScript Import Maps
  # - CSS 중첩(Nesting) 문법
  # - CSS :has() 선택자
  #
  # 오래된 브라우저(예: IE)는 업그레이드 안내 페이지로 리디렉션됩니다.
  # 이 설정을 통해 최신 웹 기술을 안전하게 사용할 수 있으며,
  # 레거시 브라우저 지원에 따른 개발 부담을 줄일 수 있습니다.
  allow_browser versions: :modern

  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new
  ) }
end
