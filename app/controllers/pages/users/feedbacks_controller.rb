class Pages::Users::FeedbacksController < Pages::UsersController
  before_action :authenticate_user
  
  def index
    render Pages::Users::Feedbacks::Index.new
  end
end