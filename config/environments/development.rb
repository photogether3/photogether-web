# config/environments/development.rb
# EDITOR="vim" bin/rails credentials:edit

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  config.time_zone = "Asia/Seoul"
  config.active_record.default_timezone = :local

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  # Change to :null_store to avoid any caching.
  config.cache_store = :memory_store

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # -------------------------------------------------------
  # Action Mailer 설정 추가 (개발 환경)
  # -------------------------------------------------------

  # 메일 전송 시 발생하는 에러를 로그로만 남기고 프로세스 중단은 안 함
  config.action_mailer.raise_delivery_errors = false

  # 실제로 메일을 발송하려면 true로 설정
  config.action_mailer.perform_deliveries = true

  # 메일링 방식: smtp / :test / :sendmail 등
  # 여기서는 smtp 사용 예시
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

  # 개발 환경에서 Mailer URL 헬퍼 사용 시 호스트 지정
  config.action_mailer.default_url_options = { host: "localhost", port: 8000 }

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # -------------------------------------------------------
  # 나머지 기존 설정들
  # -------------------------------------------------------

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # config.action_controller.raise_on_missing_callback_actions = true

  # config.generators.apply_rubocop_autocorrect_after_generate!
end
