class Views::Pages::Policies::DataDeletion < Views::Base
  def view_template
    render Views::Pages::Layout.new do
      h1(class: "mb-6 text-3xl font-bold") { "포토게더(Photogether) 데이터 및 계정 삭제 정책" }

      # 개요 섹션
      div(class: "mb-8") do
        h2(class: "mb-4 text-2xl font-semibold") { "개요" }
        p(class: "mb-4") do
          "포토게더는 사용자의 개인정보 보호를 중요시합니다. 이 페이지는 사용자가 자신의 계정과 개인 데이터를 삭제하는 방법에 대한 정보를 제공합니다."
        end
      end

      # 계정 및 데이터 삭제 방법 섹션
      div(class: "mb-8") do
        h2(class: "mb-4 text-2xl font-semibold") { "계정 및 데이터 삭제 방법" }
        p(class: "mb-2") { "사용자는 다음 방법 중 하나를 통해 계정 및 개인 데이터 삭제를 요청할 수 있습니다:" }

        # 앱 내에서 삭제
        h3(class: "mt-4 mb-2 text-xl font-semibold") { "1. 앱 내에서 삭제" }
        ol(class: "pl-6 mb-4 list-decimal") do
          li { "포토게더 앱에 로그인합니다." }
          li { "설정 메뉴로 이동합니다." }
          li { "'계정 관리'를 선택합니다." }
          li { "'계정 삭제'를 탭합니다." }
          li { "이메일 인증 또는 OTP를 통해 본인 확인을 완료합니다." }
          li { "삭제 확인 버튼을 탭하면 계정 삭제가 진행됩니다." }
        end

        # 이메일로 요청
        h3(class: "mt-4 mb-2 text-xl font-semibold") { "2. 이메일로 요청" }
        p(class: "mb-4") do
          span { "이메일을 보내 계정 삭제를 요청할 수 있습니다. 이메일에는 회원가입에 사용한 이메일 주소와 함께 \"계정 삭제 요청\"이라는 제목을 포함해주시기 바랍니다." }
          span { " " }
          a(href: "mailto:dev.goraebap@gmail.com", class: "text-blue-600 underline") { "dev.goraebap@gmail.com" }
        end
      end

      # 삭제되는 데이터 섹션
      div(class: "mb-8") do
        h2(class: "mb-4 text-2xl font-semibold") { "삭제되는 데이터" }
        p(class: "mb-2") { "계정 삭제 시 다음 데이터가 영구적으로 삭제됩니다:" }
        ul(class: "pl-6 mb-4 list-disc") do
          li { "사용자 계정 정보(이메일, 비밀번호, 프로필 정보 등)" }
          li { "업로드한 모든 사진" }
          li { "사진첩 및 카테고리" }
          li { "텍스트 메타데이터 및 코멘트" }
          li { "사용자 기본 설정 정보" }
        end
      end

      # 데이터 보관 섹션
      div(class: "mb-8") do
        h2(class: "mb-4 text-2xl font-semibold") { "데이터 보관" }
        p(class: "mb-2") { "다음 데이터는 법적 요구사항에 따라 제한된 기간 동안 보관될 수 있습니다:" }
        ul(class: "pl-6 mb-4 list-disc") do
          li { "서비스 이용 로그 기록: 3개월" }
        end
        p { "이러한 데이터는 법적 목적으로만 사용되며 보관 기간이 종료되면 자동으로 삭제됩니다." }
      end

      # 삭제 처리 기간 섹션
      div(class: "mb-8") do
        h2(class: "mb-4 text-2xl font-semibold") { "삭제 처리 기간" }
        p(class: "mb-4") do
          "계정 삭제 요청이 확인되면, 계정 및 관련 데이터는 30일 이내에 삭제됩니다. 이 기간 동안 사용자는 요청을 취소할 수 있습니다."
        end
      end

      # 업데이트 일자
      div(class: "mb-4") do
        p(class: "text-sm text-gray-600") { "최종 업데이트: 2025년 5월 5일" }
      end
    end
  end
end
