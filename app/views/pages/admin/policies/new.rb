class Views::Pages::Admin::Policies::New < Views::Base
  include Views::Pages::Admin

  def initialize(policy:)
    @policy = policy
  end

  def view_template
    render Layout.new(content_padding: false) do
      div(class: "flex items-center gap-2 p-6") do
        a(href: "/admin/policies",
          class: "text-xl") do
          raw(<<~SVG.html_safe)
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
            </svg>
          SVG
        end
      h1(class: "text-2xl") { "약관 등록" }
      end
      # 에러가 날 경우 보여지는 Alert
      # div(class: "alert alert-error rounded-none") do
      #   raw(<<~SVG.html_safe)
      #     <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
      #       <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
      #     </svg>
      #   SVG
      #   span { "작성 양식이 딱딱!" }
      # end
      # 폼 영역
      form(action: "/admin/policies", method: "post",
        data: { controller: "tinymce" },
        class: "border-y border-dashed border-base-300 flex justify-between") do
        div(class: "flex-2 p-6 border-r border-base-300 border-dashed bg-primary/5") do
          # 약관 제목 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 제목" }
            input(name: "policy[title]",
              type: "text",
              class: "input bg-white",
              placeholder: "제목을 입력하세요")
          end

          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 내용" }
            # 실제 에디터용 텍스트 영역
            textarea(id: "tinymce-editor") { @policy.content }
            # hidden 필드로 내용 전송
            input(type: "text", name: "policy[content]", id: "policy_content_hidden")
          end
        end
        div(class: "flex-1 p-6 relative") do
          # 약관 구분 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 구분" }
            select(name: "policy[kind]", class: "select bg-white") do
              option(disabled: "true", selected: "true") { "약관 구분을 선택하세요" }
              option(value: "terms") { "TERMS" }
              option(value: "privacy") { "PRIVACY" }
              option(value: "marketing") { "MARKETING" }
            end
          end
          # 약관 활성화 여부 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 활성 여부" }
            select(name: "policy[is_active]", class: "select bg-white") do
              option(value: "true", selected: "true") { "활성화" }
              option(value: "false") { "비활성화" }
            end
          end
          # 필수 동의 여부 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "필수 동의 여부" }
            select(name: "policy[is_required]", class: "select bg-white") do
              option(value: "true", selected: "true") { "필수" }
              option(value: "false") { "선택" }
            end
          end
          # 정책 버전
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "정책 버전" }
            input(name: "policy[version]", type: "number", class: "input bg-white")
          end

          div(class: "absolute right-0 bottom-0 p-4") do
            button(class: "btn btn-soft btn-secondary") { "등록하기" }
          end
        end
      end
    end
  end
end
