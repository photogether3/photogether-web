class Views::Pages::Admin::Policies::Edit < Views::Base
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

    render Policies::Form.new(policy: @policy, is_edit: true)

    div(class: "p-6 w-full text-center") do
      a(href: "/admin/policies/#{@policy.id}",
        class: "btn btn-soft btn-error",
        data: {
          turbo_method: "delete",
          turbo_confirm: "정말로 이 약관을 삭제하시겠습니까?"
        }) { "약관 삭제" }
    end
  end
end
