source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # ---------------------------------
  # 추가된 Gem
  # describe 구문을 위해 사용
  # ---------------------------------
  gem "minitest-spec-rails"
end

# ---------------------------------
# 추가된 Gem들
# ---------------------------------

# 비밀번호 암호화를 위한 라이브러리
gem "bcrypt", "~> 3.1.7"
# 이미지 처리 및 변환을 위한 라이브러리
gem "image_processing", ">= 1.2"
# API 문서화 도구
gem "scalar_ruby", "~> 1.1"
# PostgreSQL 데이터베이스 어댑터
gem "pg"
# Google Cloud Vision API를 사용한 이미지 분석
gem "google-cloud-vision"
# Cross-Origin Resource Sharing 설정을 위한 라이브러리
gem "rack-cors"
# 페이지네이션 처리를 위한 라이브러리
gem "kaminari", "~> 1.2", ">= 1.2.2"
# Ruby 기반 HTML 작성 라이브러리
gem "phlex-rails", "~> 2.3"
# 사이트맵 생성 라이브러리
gem "sitemap_generator"
# axios같은 http 클라이언트 라이브러리
gem "faraday"
