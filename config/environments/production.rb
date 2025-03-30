require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # 파일로 로그 출력하도록 수정
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.new(
    Logger.new(
      Rails.root.join("log", "#{Rails.env}.log"),
      10,     # 파일 수 (로그 로테이션)
      10.megabytes  # 각 파일 최대 크기 (10MB)
    )
  )

  # 로그 레벨 설정 (환경 변수에서 가져옴, 기본값은 info)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # 예방 조치: 헬스체크 경로는 로그에 기록하지 않음
  config.silence_healthcheck_path = "/up"

  # TODO: 관리자 활동 로그를 위한 개선 방안
  # 1. AdminLogger 서비스 클래스 구현 (app/services/admin_logger.rb)
  # 2. admin_activity.log 파일에 구조화된 JSON 형식으로 기록
  # 3. 관리자 컨트롤러에서 after_action으로 중요 활동 로깅
  # 예시 코드:
  # class AdminLogger
  #   def self.log(action, user_id, details = {})
  #     log_file = Rails.root.join('log', 'admin_activity.log')
  #     message = { timestamp: Time.current, action: action, user_id: user_id, details: details }
  #     File.open(log_file, 'a') { |f| f.puts(message.to_json) }
  #   end
  # end

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp

  # SMTP 서버 설정 (예시: Gmail SMTP)
  config.action_mailer.smtp_settings = {
    address:              "smtp.gmail.com",
    port:                 587,
    domain:               "example.com",
    user_name:            Rails.application.credentials.dig(:smtp, :user_name),
    password:             Rails.application.credentials.dig(:smtp, :password),
    authentication:       "plain",
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   "203.245.29.124",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
