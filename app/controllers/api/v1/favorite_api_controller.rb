class Api::V1::FavoriteApiController < Api::ApplicationApiController
  before_action :authenticate_user!

  def index
    render json: @current_user.favorite_categories, status: :ok
  end

  def creates_or_updates
    category_ids = params[:categoryIds]
    updated_categories = @current_user.update_favorites_usecase(category_ids)

    render json: updated_categories, status: :ok
  end
end
