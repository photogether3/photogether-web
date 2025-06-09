class Views::Pages::Home::DropDown < Views::Base
  def initialize(summary: "다운로드 앱")
    @summary = summary
  end

  def view_template
    details(class: "dropdown dropdown-end") do
      summary(class: "btn-primary pg-btn flex items-center gap-1 text-sm sm:text-md lg:text-lg") do
        span { @summary }
        raw(<<~SVG.html_safe)
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M16.445 7.0051C16.7187 7.25139 16.7409 7.67292 16.4946 7.94661L10.4952 14.6133C10.3688 14.7538 10.1887 14.834 9.9997 14.834C9.8107 14.834 9.63058 14.7538 9.50415 14.6133L3.50415 7.94663C3.25784 7.67296 3.28003 7.25143 3.5537 7.00513C3.82738 6.75882 4.2489 6.78101 4.49521 7.05468L9.99965 13.1707L15.5035 7.05471C15.7498 6.78102 16.1713 6.75881 16.445 7.0051Z" fill="white"/>
          </svg>
        SVG
      end
      div(class: "menu dropdown-content border border-primary bg-base-300 rounded-[12px] z-1 w-32 lg:w-52 p-5 shadow-sm mt-[16px]") do
        yield if block_given?
      end
    end
  end
end
