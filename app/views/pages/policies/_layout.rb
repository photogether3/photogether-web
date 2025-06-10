class Views::Pages::Policies::Layout < Views::Pages::Layout
  def view_template
    render Views::Pages::Layout.new do
      div(class: "w-full lg:py-[160px]") do
        div(class: "pg-container flex flex-col lg:flex-row gap-2 lg:gap-6 lg:border-y lg:border-[#C6C6C6] px-4 py-3 lg:py-6") do
          div(class: "hidden lg:block lg:w-[230px]") do
            a(href: "/",
              class: "rounded-4xl
              text-sm lg:text-xl
              flex justify-center items-center border border-primary bg-secondary p-[0.7em]") do
              raw(<<~SVG.html_safe)
                <svg class="text-secondary-content translate-x-[-1px] w-[20px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                </svg>
              SVG
              span { "이전으로" }
            end
          end
          div(class: "grow") do
            yield if block_given?
          end
        end
      end
    end
  end
end
