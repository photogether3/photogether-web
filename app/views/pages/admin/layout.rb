class Views::Pages::Admin::Layout < Views::Base
  include Views::Pages::Admin

  def view_template
    div(class: "flex flex-col") do
      # 헤더
      header(class: "h-14 border-b border-base-300 flex justify-center items-center p-3 gap-2 bg-primary/10") do
        div(class: "h-full p-2") do
          img(src: "/images/photogether-logo.png", class: "h-full")
        end
        div(class: "text-lg font-semibold") { "포토게더 관리" }
      end
      # 컨텐츠
      div(class: "flex h-[calc(100vh-56px)] overflow-x-auto") do
        # 사이드바
        aside(
          class: "sticky top-0 border-r border-dashed border-base-300 h-full w-[30%] min-w-[300px]
          flex flex-col items-end justify-center p-4") do
          render Sidebar.new
        end
        # 메인 컨텐츠
        main(class: "p-6 w-[70%] max-w-[1000px]") do
          yield
        end
      end
    end
  end
end
