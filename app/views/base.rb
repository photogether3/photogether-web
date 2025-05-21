# frozen_string_literal: true

class Views::Base < Phlex::HTML
  include Phlex::Rails::Helpers

  def initialize
  end

  def current_path?(path)
    rails_view_context = @_state&.instance_variable_get(:@user_context)&.fetch(:rails_view_context, nil)
    rails_view_context&.request&.path == path
  end
end
