class Views::Shared::Components::Modal < Views::Base
  def initialize(title: "")
    @title = title
  end

  def view_template
    turbo_frame(id: "modal_overlay") do
      # 오버레이 - 클릭 이벤트 추가
      div(
        data: {
          controller: "modal",
          action: "click->modal#onOverlayClick"
        },
        class: "fixed inset-0 bg-base-300/50 z-50 overflow-y-auto py-20 px-4 motion-preset-fade-lg") do
        div(
          class: "bg-base-100 max-w-[560px] rounded-box mx-auto h-auto overflow-hidden motion-preset-slide-up",
          data: { action: "click->modal#onModalClick" }) do  # 모달 클릭 이벤트 추가
          # 해더박스
          div(class: "p-6 flex items-center justify-between") do
            # 타이틀
            div do
              if @title
                h2(class: "text-2xl") { @title }
              end
            end
            # 닫기버튼
            button(
              data: {
                action: "modal#onClose"
              },
              class: "text-primary-content") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                </svg>
              SVG
            end
          end
          # 컨텐츠박스
          div do
            yield
          end
        end
      end
    end
  end
end
