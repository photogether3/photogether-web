module BaseActionable
  extend ActiveSupport::Concern

  class_methods do
    def create_with(strategy)
      transaction do
        strategy.create
      end
    rescue ActiveRecord::RecordInvalid, StandardError => e
      Rails.logger.error("생성 실패: #{e.message}")
      raise e
    end
  end
end
