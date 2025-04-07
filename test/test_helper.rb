ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    setup do
      # 예: 기본 역할 추가
      puts "테스트 환경 설정 중..."
      puts "기본 역할 추가 중..."
      unless Role.exists?(id: 1)
        Role.create!(id: 1, name: "user")
      end
    end
  end
end
