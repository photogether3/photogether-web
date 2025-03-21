class Admin::AdminController < ApplicationController
  allow_unauthenticated_access

  layout "admin"
end
