# Google Vision API 초기화 설정
# 이 초기화 파일을 사용하려면 GCP에서 발급받은 JSON 키 파일이 필요하다.
# 해당 파일은 config/vision-key.json 경로에 위치해야 하며,
# 반드시 .gitignore에 포함되어야 한다.

require "google/cloud/vision"

Google::Cloud::Vision.configure do |config|
  config.credentials = Rails.root.join("config/vision-key.json").to_s
end

puts "[Vision] Google Cloud Vision 초기화 완료"
