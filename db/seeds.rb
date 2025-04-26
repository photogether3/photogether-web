# Role 생성
Role.find_or_create_by!(name: 'User')
Role.find_or_create_by!(name: 'Admin')

# User 생성
User.find_or_create_by!(email_address: Rails.application.credentials.dig(:admin, :email)) do |user|
  user.password = Rails.application.credentials.dig(:admin, :password)
  user.password_confirmation = Rails.application.credentials.dig(:admin, :password)
  user.role_id = 2
  user.nickname = '관리자'
  user.is_email_verified = true
end

# Category 생성
categories = [
  { id: 1001, name: '기술' },
  { id: 1002, name: '건강 & 웰니스' },
  { id: 1003, name: '여행' },
  { id: 1004, name: '금융' },
  { id: 1005, name: '음식 & 요리' },
  { id: 1006, name: '엔터테인먼트' },
  { id: 1007, name: '교육' },
  { id: 1008, name: '스포츠' },
  { id: 1009, name: '비즈니스' },
  { id: 1010, name: '라이프스타일' }
]

categories.each do |category|
  Category.find_or_create_by!(id: category[:id]) do |c|
    c.name = category[:name]
  end
end

# 기본 정책들 생성하기
policies = [
  {
    title: '서비스 이용약관',
    kind: 'terms',
    content: '<h1>서비스 이용약관</h1><p>본 약관은 포토게더(이하 "회사")가 제공하는 서비스의 이용 조건을 정의합니다.</p><h2>1. 정의</h2><p>본 약관에서 사용하는 용어의 정의는 다음과 같습니다.</p><p>"서비스"란 회사가 제공하는 모든 서비스를 의미합니다.</p>',
    version: '1.0',
    is_active: true,
    is_required: true,
    effective_date: Time.current
  },
  {
    title: '개인정보처리방침',
    kind: 'privacy',
    content: '<h1>개인정보처리방침</h1><p>포토게더(이하 "회사")는 사용자의 개인정보를 중요하게 생각하며 다음과 같은 방침을 준수합니다.</p><h2>1. 수집하는 개인정보</h2><p>회사는 서비스 제공을 위해 다음과 같은 개인정보를 수집할 수 있습니다.</p><ul><li>필수 항목: 이메일 주소, 비밀번호</li><li>선택 항목: 프로필 정보, 관심사</li></ul>',
    version: '1.0',
    is_active: true,
    is_required: true,
    effective_date: Time.current
  },
  {
    title: '마케팅 정보 수신 동의',
    kind: 'marketing',
    content: '<h1>마케팅 정보 수신 동의</h1><p>포토게더(이하 "회사")가 제공하는 이벤트 및 혜택 정보를 수신하는 것에 동의합니다.</p><p>언제든지 수신 동의를 철회할 수 있으며, 이 경우 회사는 마케팅 정보 발송을 중단합니다.</p>',
    version: '1.0',
    is_active: true,
    is_required: false,
    effective_date: Time.current
  }
]

policies.each do |policy_data|
  policy = Policy.find_or_initialize_by(kind: policy_data[:kind], version: policy_data[:version])

  # 새로운 정책이거나 내용 업데이트가 필요한 경우만 속성 설정
  policy.title = policy_data[:title]
  policy.content = policy_data[:content]
  policy.is_active = policy_data[:is_active]
  policy.effective_date = policy_data[:effective_date]
  policy.is_required = policy_data[:is_required]

  policy.save!
end
