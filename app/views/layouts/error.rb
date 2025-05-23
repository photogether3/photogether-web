class Views::Layouts::Error < Views::Base
  include Phlex::Rails::Layout
  include Phlex::Rails::Helpers::ContentFor

  def view_template
    doctype
    html(data: { theme: "lemonade" }, lang: "ko") do
      head do
        title { content_for(:title) || "포토게더" }
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "mobile-web-app-capable", content: "yes")

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
        yield
      end
    end
  end
end
