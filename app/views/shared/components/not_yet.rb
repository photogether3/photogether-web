class Views::Shared::Components::NotYet < Views::Base
  def initialize
    @links = [
      "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbDNncWluZGxyOHUwN2JobWdlanhqbDVzcDFlNjA4aGxicm1uc3YzbiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/O2cGCtKd9ZBMgxgzsW/giphy.gif",
      "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExc3l1a3gxODd4ZWM5YWwzMTkzcGx2cmlicG4wcDc5bmtpN3kxbzRkNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/dBsUACbhvDROt9pbFO/giphy.gif",
      "https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExMmZqdXRwdmU2amIxMG5vdzNocXFyMW9ycnFkam1nd2Jibm1lNWQ0ZSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/m0MfjLtKOgTPG/giphy.gif",
      "https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExY3h2bDI5bjE4NHViNDV5N2ZkcHNsNXE5OGs1cXYwZXZ0czM2aGF1OCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/UHAYP0FxJOmFBuOiC2/giphy.gif",
      "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExd3pjZXU1cTJ5dHlibGQ4bzZzMmVwbXc0N2tkc3dsMXBnN3N5enVvciZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/ch1pcRhEb0c1y/giphy.gif"
    ]

    # 랜덤하게 링크 선택
    @random_link = @links.sample
  end

  def view_template
    turbo_frame(id: "not_yet") do
      # 오버레이
      div(
        data: { controller: "not_yet" },
        class: "fixed right-0 bottom-0 p-4 z-50") do
        img(src: @random_link, alt: "준비 중인 기능입니다", class: "rounded-lg shadow-lg")
      end
    end
  end
end
