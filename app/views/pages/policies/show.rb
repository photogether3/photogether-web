class Views::Pages::Policies::Show < Views::Base
  def initialize(policy:)
    @policy = policy
  end

  def view_template
    # html 컨텐츠 랜더링
    div(class: "prose prose-sm max-w-none") do
      raw(@policy.content.to_s.html_safe)
    end
  end
end
