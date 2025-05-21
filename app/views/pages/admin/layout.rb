class Views::Pages::Admin::Layout < Views::Base
  include Views::Pages::Admin

  def view_template
    div(class: "flex flex-col") do
      # 헤더
      header(class: "h-14 border-b border-base-300 flex justify-center items-center p-3 gap-2") do
        div(class: "h-full") do
          img(src: "/images/photogether-logo.png", class: "h-full")
        end
        div(class: "text-xl font-bold") { "포토게더 관리" }
      end
      # 컨텐츠
      div(class: "flex h-[calc(100vh-56px)] overflow-x-auto") do
        # 사이드바
        render Sidebar.new
        # 메인 컨텐츠
        main(class: "p-4") do
          yield
        end
      end
    end
  end
end
