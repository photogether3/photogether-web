class Views::Pages::Admin::Users::Index < Views::Base
  include Views::Pages::Admin

  def initialize(users:)
    @users = users
  end

  def view_template
    div(class: "flex justify-between items-center p-6") do
      h1(class: "text-2xl") { "회원 관리" }
    end
    div(class: "bg-base-100 p-6 border-t border-dashed border-base-300") do
      div(class: "overflow-x-auto") do
        table(class: "table") do
          thead(class: "bg-base-200") do
            tr do
              th
              th { "프로필" }
              th { "이메일" }
              th { "닉네임" }
              th { "이메일인증여부" }
              th { "생성일" }
              th { "변경일" }
              th
            end
          end
          tbody do
            @users.each_with_index do |user, i|
              tr do
                td { i+1 }
                td do
                  div(class: "avatar") do
                    div(class: "w-8 rounded") do
                      img(
                        src: user[:image_url] ? user[:image_url] : "https://img.daisyui.com/images/profile/demo/superperson@192.webp",
                        alt: "Tailwind-CSS-Avatar-component")
                    end
                  end
                end
                td do
                  a(href: "/admin/users/#{user[:id]}", class: "text-primary") { user[:email] }
                end
                td do
                  user[:nickname]
                end
                td { user[:is_email_verified] ? "인증" : "미인증" }
                td { user[:created_at]&.strftime("%Y-%m-%d %H:%M:%S") }
                td { user[:updated_at]&.strftime("%Y-%m-%d %H:%M:%S") }
              end
            end
          end
        end
      end
    end
  end
end
