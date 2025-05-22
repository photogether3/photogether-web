class Views::Pages::Admin::Policies::Index < Views::Base
  include Views::Pages::Admin

  def initialize(policies:)
    puts policies.inspect
    @policies = policies
  end

  def view_template
    render Layout.new do
      h1 { "약관 관리 페이지" }
      div do
        table do
          thead do
            tr do
              th { "순번" }
              th { "ID" }
              th { "제목" }
              th { "약관타입" }
            end
          end
          tbody do
          end
        end
      end
    end
  end
end
