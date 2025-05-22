class Views::Pages::Admin::Policies::New < Views::Base
  include Views::Pages::Admin

  def initialize(policy:, alert: nil)
    @policy = policy
    @alert = alert
  end

  def safe_date_string(date_value)
    return Date.current.to_s if date_value.nil?

    begin
      date_value.respond_to?(:to_date) ? date_value.to_date.to_s : Date.current.to_s
    rescue
      Date.current.to_s
    end
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

      # 에러/경고가 있을 경우 알림 표시
      if @alert
        div(class: "alert alert-error rounded-none mb-4") do
          raw(<<~SVG.html_safe)
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 shrink-0 stroke-current" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          SVG
          span { @alert }
        end
      end

      # 폼 영역
      form(action: "/admin/policies", method: "post",
        data: { controller: "tinymce" },
        class: "border-y border-dashed border-base-300 flex justify-between") do
        # CSRF 토큰 추가
        input(type: "hidden", name: "authenticity_token", value: helpers.form_authenticity_token)

        div(class: "flex-2 p-6 border-r border-base-300 border-dashed bg-primary/5") do
          # 약관 제목 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 제목" }
            input(name: "policy[title]",
              type: "text",
              value: @policy.title,
              class: "input bg-white",
              placeholder: "제목을 입력하세요")
          end

          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 내용" }
            # 실제 에디터용 텍스트 영역
            textarea(id: "tinymce-editor") { @policy.content }
            # hidden 필드로 내용 전송
            input(type: "hidden", name: "policy[content]", id: "policy_content_hidden", value: @policy.content)
          end
        end

        div(class: "flex-1 p-6 relative") do
          # 약관 구분 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 구분" }
            select(name: "policy[kind]", class: "select bg-white") do
              option(disabled: "true", selected: @policy.kind.blank?) { "약관 구분을 선택하세요" }
              option(value: "terms", selected: @policy.kind == "terms") { "TERMS" }
              option(value: "privacy", selected: @policy.kind == "privacy") { "PRIVACY" }
              option(value: "marketing", selected: @policy.kind == "marketing") { "MARKETING" }
            end
          end

          # 약관 활성화 여부 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "약관 활성 여부" }
            select(name: "policy[is_active]", class: "select bg-white") do
              option(value: "true", selected: @policy.is_active) { "활성화" }
              option(value: "false", selected: !@policy.is_active) { "비활성화" }
            end
          end

          # 필수 동의 여부 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "필수 동의 여부" }
            select(name: "policy[is_required]", class: "select bg-white") do
              option(value: "true", selected: @policy.is_required) { "필수" }
              option(value: "false", selected: !@policy.is_required) { "선택" }
            end
          end

          # 정책 효력 일자 필드
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "정책 효력 일자" }
            input(name: "policy[effective_date]",
                  type: "date",
                  value: safe_date_string(@policy.effective_date),
                  class: "input bg-white",
                  placeholder: "YYYY-MM-DD")
          end

          # 정책 버전
          fieldset(class: "fieldset") do
            legend(class: "fieldset-legend") { "정책 버전" }
            input(name: "policy[version]",
                  type: "number",
                  value: @policy.version || 1.0,
                  step: "0.1",
                  class: "input bg-white")
          end

          div(class: "absolute right-0 bottom-0 p-4") do
            button(type: "submit", class: "btn btn-soft btn-secondary") { "등록하기" }
          end
        end
      end
    end
  end
end
