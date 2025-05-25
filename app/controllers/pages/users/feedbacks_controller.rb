class Pages::Users::FeedbacksController < Pages::UsersController
  def index
    render Pages::Users::Feedbacks::Index.new
  end
end