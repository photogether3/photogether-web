class Views::Pages::Admin::Layout < Views::Base
  include Views::Pages::Admin

  def initialize(content_padding: true)
    # 기본적으로는 컨텐츠 영역에 패딩이 들어가있음
    # 레이아웃을 사용하는 시점에 명시적으로 false 값을 주어 패딩을 사용하지 않을 수 있음
    @content_padding = content_padding
  end

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
          class: "sticky top-0 border-r border-dashed border-base-300 h-full w-[25%] min-w-[300px]
          flex flex-col items-end justify-center p-4") do
          render Sidebar.new
        end
        # 메인 컨텐츠
        main(class: "w-[70%] max-w-[1000px] #{ 'p-6' if @content_padding }") do
          yield
        end
      end
    end
  end
end
