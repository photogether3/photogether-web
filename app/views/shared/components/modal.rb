class Views::Shared::Components::Modal < Views::Base
  def initialize(title: "")
    @title = title
  end

  def view_template
    turbo_frame(id: "modal_overlay") do
      # 오버레이
      div(
        data: { controller: "modal" },
        class: "fixed inset-0 bg-base-content/50 z-50 overflow-y-auto py-20 px-4") do
        # 모달 박스
        div(class: "bg-base-100 w-full max-w-lg rounded-box mx-auto h-auto overflow-hidden") do
          # 해더박스
          div(class: "p-6 flex items-center justify-between") do
            # 타이틀
            h2(class: "text-2xl") { @title }
            # 닫기버튼
            button(
              data: {
                action: "modal#onClose"
              },
              class: "btn btn-soft btn-error") do
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
