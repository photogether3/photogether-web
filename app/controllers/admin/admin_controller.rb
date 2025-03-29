class Admin::AdminController < ApplicationController
  allow_unauthenticated_access
  http_basic_authenticate_with  name: Rails.application.credentials.dig(:admin, :email),
                                password: Rails.application.credentials.dig(:admin, :password)

  layout "admin"
end
