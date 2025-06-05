class Views::Layouts::Application < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor

  def initialize(layout: nil)
    # 레이아웃 컴포넌트 클래스 주입
    @layout = layout
  end

  def view_template
    doctype
    html(data: { theme: "photogether-dark" }, lang: "ko") do
      head do
        title { content_for(:title) || "포토게더" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")

        meta(name: "description", content: "포토게더(Photogether)는 사진 공유 및 앨범 관리 서비스입니다. 소중한 순간을 기록하고 가족, 친구들과 함께 공유하세요.")
        meta(name: "keywords", content: "포토게더, photogether, 사진 공유, 앨범 관리, 사진첩, 포토 앨범")
        meta(name: "language", content: "Korean")
        meta(property: "og:locale", content: "ko_KR")

        # Rails 헬퍼 메소드
        csrf_meta_tags
        csp_meta_tag

        # yield :head 대체
        content_for(:head) if content_for?(:head)

        # 아이콘 및 스타일시트
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        link(rel: "stylesheets", href: "/font.css")

        # Vite 에셋 - 헬퍼 메서드를 명시적으로 호출
        raw helpers.vite_asset_tags("main")

        # TinyMCE 스크립트
        script(src: "https://cdn.tiny.cloud/1/g7rvccst0a48ydu2wia7fbtgab2h5usfhw0ggzseok12l0wq/tinymce/7/tinymce.min.js", referrerpolicy: "origin")
      end

      body do
        if @layout.nil?
          yield
        else
          render @layout do
            yield
          end
        end

        # Flash 박스
        div(class: "fixed right-0 top-0 p-6 z-50") do
          if helpers.notice
            div(
              data: { controller: "flash" },
              class: "alert alert-success") do
                raw(<<~SVG.html_safe)
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                SVG
                span { helpers.notice }
              end
          end

          if helpers.alert
            div(
              data: { controller: "flash" },
              class: "alert alert-error") do
                raw(<<~SVG.html_safe)
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                SVG
                span { helpers.alert }
              end
          end
        end

        turbo_frame(id: "modal_overlay") do
        end

        turbo_frame(id: "not_yet") do
        end
      end
    end
  end
end
