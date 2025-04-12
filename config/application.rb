require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PhotogetherWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths << Rails.root.join("app", "errors")
    config.autoload_paths << Rails.root.join("app", "services")
    config.autoload_paths << Rails.root.join("app", "libs")
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Asia/Seoul"
    config.active_record.default_timezone = :local
    # config.eager_load_paths << Rails.root.join("extras")

    ## CORS 설정 추가
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*" # 필요한 도메인으로 변경 가능
        resource "*",
          headers: :any,
          methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
          expose: [ "Authorization" ]
      end
    end
  end
end
