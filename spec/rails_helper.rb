# 이 파일은 'rails generate rspec:install'을 실행할 때 spec/ 디렉토리에 복사됩니다
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# 프로덕션 환경에서 데이터베이스가 truncate되는 것을 방지합니다
abort("Rails 환경이 프로덕션 모드로 실행 중입니다!") if Rails.env.production?
require 'rspec/rails'
# 이 줄 아래에 추가적인 require 문을 넣으세요. 이 지점까지는 Rails가 로드되지 않습니다!

# spec/support/ 및 그 하위 디렉토리에 있는 사용자 정의 matcher와 매크로 등을 위한 Ruby 파일이 필요합니다.
# 기본적으로 `spec/**/*_spec.rb`와 일치하는 파일은 스펙 파일로 실행됩니다.
# 이는 spec/support에서 _spec.rb로 끝나는 파일이 required 되고 스펙으로도 실행되어
# 스펙이 두 번 실행된다는 것을 의미합니다. _spec.rb로 끝나는 파일을 이 글로브와 일치시키지 않는 것이 좋습니다.
# 이 패턴은 명령줄이나 ~/.rspec, .rspec 또는 `.rspec-local`에서 --pattern 옵션으로 구성할 수 있습니다.
#
# 다음 줄은 편의를 위해 제공됩니다. support 디렉토리에 있는 모든 파일을 자동으로 요구함으로써
# 부팅 시간이 증가하는 단점이 있습니다. 대안으로, 개별 `*_spec.rb` 파일에서
# 필요한 지원 파일만 수동으로 require할 수 있습니다.
#
# 이 줄의 주석을 해제하여 spec/support 디렉토리의 모든 파일을 자동으로 로드합니다
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# 테스트가 실행되기 전에 보류 중인 마이그레이션이 있는지 확인하고 적용합니다.
# ActiveRecord를 사용하지 않는 경우 이 줄을 제거할 수 있습니다.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # ActiveRecord 픽스처를 사용하지 않는 경우 이 줄을 제거하세요
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # ActiveRecord를 사용하지 않거나 각 예제를 트랜잭션 내에서 실행하고 싶지 않은 경우,
  # 다음 줄을 제거하거나 true 대신 false를 할당하세요.
  config.use_transactional_fixtures = true

  # ActiveRecord 지원을 완전히 끄려면 이 줄의 주석을 해제하세요.
  # config.use_active_record = false

  # RSpec Rails는 파일 위치에 따라 다른 동작을 자동으로 혼합할 수 있습니다.
  # 예를 들어 `spec/controllers` 아래의 스펙에서 `get`과 `post`를 호출할 수 있게 합니다.
  #
  # 아래 줄을 제거하고 대신 명시적으로 스펙에 유형을 태그하여 이 동작을 비활성화할 수 있습니다:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # 사용 가능한 다양한 유형은 https://rspec.info/features/6-0/rspec-rails 의 기능에 문서화되어 있습니다
  config.infer_spec_type_from_file_location!

  # Rails 젬에서 발생한 백트레이스 라인을 필터링합니다.
  config.filter_rails_from_backtrace!
  # 임의의 젬도 다음과 같이 필터링할 수 있습니다:
  # config.filter_gems_from_backtrace("gem name")

  # Factory Bot 설정 추가
  config.include FactoryBot::Syntax::Methods
end
