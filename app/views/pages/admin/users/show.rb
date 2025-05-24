class Views::Pages::Admin::Users::Show < Views::Base
  def initialize(user:, favorite_categories: [], posts: [])
    @user = user
    @favorite_categories = favorite_categories
    @posts = posts
  end

  def view_template
    div(class: "flex items-center gap-2 p-6") do
      a(href: "/admin/users",
        class: "text-xl") do
        raw(<<~SVG.html_safe)
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
        SVG
      end
      h2(class: "text-2xl") { "회원 상세 조회" }
    end
    div(class: "flex flex-col gap-4 p-6 border-t border-dashed border-base-300") do
      h3(class: "text-xl") { "기본 정보" }
      div(class: "flex gap-6") do
        div do
          div(class: "avatar") do
            div(class: "w-24 rounded") do
              img(
                src: @user[:image_url] ? @user[:image_url] : "/icon.png",
                alt: "profile image")
            end
          end
        end
        div(class: "flex gap-1 text-sm") do
          div(class: "flex flex-col gap-1 border-r border-base-300 pr-2") do
            span { "이메일" }
            span { "닉네임" }
            span { "자기소개" }
            span { "이메일 인증여부" }
            span { "생성일자" }
            span { "수정일자" }
          end
          div(class: "shrink flex flex-col gap-1 pl-2") do
            span { @user[:email] }
            span { @user[:nickname] }
            span { @user[:bio] }
            span { @user[:is_email_verified] ? "인증" : "미인증" }
            span { @user[:created_at]&.strftime("%Y-%m-%d %H:%M:%S") }
            span { @user[:updated_at]&.strftime("%Y-%m-%d %H:%M:%S") }
          end
        end
      end
    end
    div(class: "flex flex-col gap-4 p-6 border-t border-dashed border-base-300") do
      h3(class: "text-xl") { "관심 카테고리" }
      div(class: "flex flex-wrap gap-4") do
        @favorite_categories.each do |category|
          div(class: "text-sm text-base-content bg-base-200 rounded-md border-box p-1") { "##{category[:name]}" }
        end
      end
    end
    div(class: "flex flex-col gap-4 p-6 border-t border-dashed border-base-300") do
      h3(class: "text-xl") { "게시물" }
      div(class: "flex flex-wrap gap-4") do
        @posts.each do |post|
          # 카드 전체 컨테이너
          div(class: "w-[calc(33.33%-1rem)] min-w-[200px] overflow-hidden flex flex-col") do
            # 이미지 컨테이너 (aspect-square 유지)
            div(class: "aspect-square rounded-t-lg overflow-hidden") do
              img(
                src: post.dig(:images, :grid),
                class: "w-full h-full object-cover transition-transform hover:scale-105"
              )
            end
            # 사진첩 정보 컨테이너
            div(class: "flex items-center gap-2 bg-base-200 p-2 rounded-b-lg text-sm truncate") do
              raw(<<~SVG.html_safe)
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  class="h-4 w-4 stroke-current">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
                </svg>
              SVG
              span { post.dig(:collection, :title) }
            end
          end
        end
      end
    end
  end
end
