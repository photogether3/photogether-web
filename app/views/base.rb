# frozen_string_literal: true

class Views::Base < Phlex::HTML
  include Phlex::Rails::Helpers

  def initialize
  end

  def current_path?(path, options = {})
    rails_view_context = @_state&.instance_variable_get(:@user_context)&.fetch(:rails_view_context, nil)
    current_path = rails_view_context&.request&.path

    return false unless current_path

    # 기본적으로는 정확한 경로 매치
    if options[:start_with]
      # start_with 옵션이 true이면 경로의 시작 부분만 비교
      current_path.start_with?(path)
    else
      # 그렇지 않으면 정확한 경로 일치 확인
      current_path == path
    end
  end
end
