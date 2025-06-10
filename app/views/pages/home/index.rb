class Views::Pages::Home::Index < Views::Base
  def view_template
    section do
      div(class: "px-4 bg-gradient-to-b from-base-300/30 to-base-300 overflow-hidden border-b border-[#A6A6A6]") do
        div(class: "pg-container") do
          div(class: "flex flex-col gap-3 mt-10 sm:mt-12 lg:mt-16") do
            div(class: "text-[28px] sm:text-4xl lg:text-[50px] lg:leading-[150%] font-bold text-center") do
              h2 { "캡처만 하면 쇼핑 준비 끝!" }
              h2 { "쇼핑 비서 ‘포토게더’" }
            end

            div(class: "text-[#C6C6C6] text-center") do
              div(class: "text-sm sm:hidden") do
                p { "“나중에 다시 보려고 캡처했는데, 너무 많아서 결국 못 찾은 적 있으시죠?” 스크린샷 속 정보를 자동으로 정리해, 언제든 쉽게 꺼내볼 수 있게 도와드려요." }
              end

              div(class: "hidden sm:block text-lg") do
                p { "“나중에 다시 보려고 캡처했는데, 너무 많아서 결국 못 찾은 적 있으시죠?”" }
                p { "스크린샷 속 정보를 자동으로 정리해, 언제든 쉽게 꺼내볼 수 있게 도와드려요." }
              end
            end
          end

          div(class: "flex justify-center py-10 sm:py-14") do
            div(class: "flex gap-2 sm:gap-6 lg:gap-10") do
              render Views::Pages::Home::StoreButton.new(platform: "ios")
              render Views::Pages::Home::StoreButton.new(platform: "android")
            end
          end

          div(class: "relative flex justify-center") do
            # 단말기 이미지 박스
            # 해당 박스를 기준으로 장식용 컨텐츠들 배치
            div(class: "relative w-[300px] sm:w-[500px] lg:w-[987px] translate-x-1/10") do
              # 백그라운드 장식 1
              img(src: "/images/landing/section01/item02.png",
                  class: "absolute -left-8 top-14 sm:-left-20 sm:top-24 lg:-left-28 lg:top-48
                  w-[60px] sm:w-[130px] lg:w-[200px] object-contain")

              # 백그라운드 장식 2
              img(src: "/images/landing/section01/item06.png",
                  class: "absolute right-16 top-16 sm:right-16 sm:top-26 lg:right-52 lg:top-52
                  w-[40px] sm:w-[100px] lg:w-[136px] object-contain")

              # 단말기 이미지
              img(src: "/images/landing/section01/item04.png", class: "object-contain animate-float z-[1]")

              # 포그라운드 장식 1
              render Views::Pages::Home::Alert.new(
                tw_class: "absolute left-[40%] top-[70%] translate-x-[-160%] translate-y-[-70%] z-[3]"
              )

              # 하단 불투명 박스
              div(class: "absolute w-full h-1/2 left-0 bottom-0 bg-gradient-to-t from-base-300 to-base-300/0 z-[2]")

              # 포그라운드 장식 2
              render Views::Pages::Home::BottomSheet.new(
                tw_class: "absolute left-[90%] bottom-0 translate-x-[-90%] z-[10]"
              )
            end
          end
        end
      end
    end

    section do
      div(class: "bg-gradient-to-b from-base-300/0 to-base-300/60") do
        div(class: "pg-container lg:pb-[180px]") do
          # 상단 텍스트 영역
          div(class: "px-4") do
            div(class: "flex flex-col gap-[10px] py-10
                lg:w-full lg:flex-row-reverse lg:justify-between lg:py-30") do
              div(class: "flex items-center gap-8") do
                div(class: "w-[32px] lg:w-[52px]") do
                  img(src: "/images/landing/section02/item01.png", class: "w-full")
                end
                div(class: "text-xl lg:text-4xl font-bold leading-[150%]") do
                  p { "텍스트를 자동으로 추출하고," }
                  p { "필요할 땐 바로 꺼내보세요." }
                end
              end
              div(class: "flex items-center gap-8") do
                div(class: "w-[32px] lg:hidden") do
                end
                div(class: "text-sm lg:text-lg leading-[150%] text-[#C6C6C6]") do
                  p { "캡처한 이미지 속 텍스트를 자동으로 읽고," }
                  p { "태그와 폴더로 알아서 정리해두니까" }
                  p { "나중엔 검색만으로 쉽게 다시 찾을 수 있어요." }
                end
              end
            end
          end

          # 이미지 영역
          render Views::Pages::Home::HorizontalScrollBox.new(tw_class: "flex gap-2 lg:gap-6") do
            div(class: "min-w-[160px]") do
              img(src: "/images/landing/section02/item02.png", class: "object-contain")
            end
            div(class: "min-w-[160px]") do
              img(src: "/images/landing/section02/item03.png", class: "object-contain")
            end
            div(class: "min-w-[160px]") do
              img(src: "/images/landing/section02/item04.png", class: "object-contain")
            end
          end

          div(class: "py-20 px-4") do
            # 상단 텍스트 영역
            div(class: "flex flex-col gap-[10px] py-10
                lg:w-full lg:flex-row lg:justify-between lg:items-end lg:pt-45 lg:pb-0") do
              div(class: "flex items-center lg:flex-col lg:items-start gap-8") do
                div(class: "w-[32px] lg:w-[52px]") do
                  img(src: "/images/landing/section02/item05.png", class: "w-full")
                end
                div(class: "text-xl lg:text-4xl font-bold leading-[150%]") do
                  p { "캡처로 시작해요." }
                  p { "정리는 우리가 알아서 할게요." }
                end
              end
              div(class: "flex items-center gap-8") do
                div(class: "w-[32px] lg:hidden") do
                end
                div(class: "text-sm lg:text-lg leading-[150%] text-[#C6C6C6]") do
                  p { "지금 시작하면 스크린샷이" }
                  p { "깔끔하게 정리되기 시작합니다." }

                  div(class: "hidden lg:flex justify-end mt-[28px]") do
                    render download_dropbox
                  end
                end
              end
            end

            # 이미지 영역 (모바일용)
            div(class: "flex items-end justify-between mt-10 sm:hidden") do
              div(class: "w-[188px] relative") do
                img(src: "/images/landing/section02/item07.png", class: "object-contain")
              end
              div(class: "flex flex-col gap-[13px]") do
                # 스탭박스
                render Views::Pages::Home::StepBox.new(
                  title: "스크린샷을 찍어주세요.",
                  step: "01",
                  content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요.",
                  active: true
                )

                # 컨트롤러 박스
                div(class: "flex gap-[13px]") do
                  # 네비게이터 표시등
                  div(class: "flex justify-center items-center gap-[2px] p-[13px] bg-[#2A2C34] rounded-2xl border border-white/20") do
                    div(class: "bg-primary rounded-full w-[12px] h-[5px]")
                    div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
                    div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
                    div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
                  end

                  div(class: "flex gap-2") do
                    div(class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
                      raw(<<~SVG.html_safe)
                        <svg class="text-secondary-content translate-x-[-1px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                        </svg>
                      SVG
                    end
                    div(class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
                      raw(<<~SVG.html_safe)
                        <svg class="text-secondary-content translate-x-[1px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                        </svg>
                      SVG
                    end
                  end
                end
              end
            end
            # 이미지 영역 (데스크탑용)
            div(class: "hidden sm:flex w-[1104px] gap-[80px] items-end") do
              div(class: "w-[700px] h-[464px] flex flex-wrap gap-[25px]") do
                render Views::Pages::Home::StepBox.new(dummy: true)
                render Views::Pages::Home::StepBox.new(
                  title: "스크린샷을 찍어주세요.",
                  step: "01",
                  content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요.",
                  active: true
                )
                render Views::Pages::Home::StepBox.new(
                  title: "업로드를 눌러주세요.",
                  step: "02",
                  content: "불러오고 싶은 스크린샷을 선택한 후, ‘업로드’ 버튼을 눌러 포토게더에 등록해보세요"
                )
                render Views::Pages::Home::StepBox.new(dummy: true)
                render Views::Pages::Home::StepBox.new(
                  title: "텍스트를 추출 합니다.",
                  step: "03",
                  content: "스크린샷 안에 담긴 문구와 정보를 자동으로 분석해, 텍스트 형태로 깔끔하게 정리해드립니다."
                )
                render Views::Pages::Home::StepBox.new(
                  title: "폴더로 정리하세요.",
                  step: "04",
                  content: "정리 기준은 사용자 마음대로! 폴더를 직접 선택해 필요한 대로 분류할 수 있어요."
                )
              end

              div(class: "h-full") do
                img(src: "/images/landing/section02/item07.png", class: "object-contain")
              end
            end
          end
        end
      end
    end

    section do
      div(class: "bg-black py-[40px] lg:py-[80px] border-y border-[#A6A6A6]") do
        div(class: "pg-container") do
          div(class: "flex flex-col gap-[40px] lg:flex-row lg:justify-between lg:gap-0") do
            div(class: "flex items-start gap-[30px] lg:flex-col lg:gap-[16px] px-4") do
              img(src: "/images/landing/section03/item01.png", class: "w-[32px] lg:w-[52px] object-contain")
              div(class: "text-xl lg:text-3xl leading-[150%] font-bold") do
                p { "실제로 써본 사용자들이" }
                p { "직접 인정한 정리의 편리함." }
              end
            end

            render Views::Pages::Home::HorizontalScrollBox.new do
              render Views::Pages::Home::Review.new(
                reviewer: "Oh******",
                content: "원래 스크린샷을 엄청 자주 찍는 편인데, 막상 나중에 뭘 위해 찍었는지 기억도 안 나고 찾기도 어려웠어요. 포토게더는 그런 스크린샷들을 텍스트로 추출해서 정리해주고, 폴더로 구분해서 저장해주니까 진짜 유용해요. 특히 폴더를 제가 원하는 대로 만들 수 있어서 나만의 정리 방식으로 쓸 수 있다는 게"
              )
              render Views::Pages::Home::Review.new(
                reviewer: "Kang******",
                content: "앱 덕분에 위시리스트를 이렇게 간편하게 정리할 수 있다니 정말 놀라워요! 스크린샷 속 텍스트를 정확하게 인식해 주니까 따로 메모할 필요 없이 곧바로 저장할 수 있었고, 갤러리가 자동으로 깔끔하게 분류되어서 원하는 이미지를 빠르게 찾아볼 수 있더라구요. 게다가 관리자의 피드백 처리 속도가 엄"
              )
            end
          end
        end
      end
    end

    section do
      # 모바일
      div(class: "flex justify-center py-10 sm:py-14 lg:hidden") do
        div(class: "flex gap-2 sm:gap-6") do
          a(href: "/not-yet", data: { turbo_method: "get", turbo_frame: "not_yet" }) do
            img(src: "/images/landing/section01/appstore.png", class: "w-[139px] object-contain")
          end
          a(href: "/not-yet", data: { turbo_method: "get", turbo_frame: "not_yet" }) do
            img(src: "/images/landing/section01/googleplay.png", class: "w-[139px] object-contain")
          end
        end
      end
      # 데스크탑
      div(class: "hidden lg:flex justify-center py-[120px]") do
        img(src: "/images/landing/section04/item01.png", class: "w-[1280px] h-[625px]")
      end
    end
  end

  private

  def download_dropbox
    Views::Pages::Home::DropDown.new do
      div(class: "flex flex-col gap-5") do
        render Views::Pages::Home::StoreButton.new(platform: "ios")
        div(class: "w-full border border-white/20")
        render Views::Pages::Home::StoreButton.new(platform: "android")
      end
    end
  end
end
