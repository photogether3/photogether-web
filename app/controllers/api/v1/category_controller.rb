class Api::V1::CategoryController < Api::ApplicationApiController
  def index
    puts "Category index"
    categories = Category.order(:id)
    render json: categories, status: :ok
  end

  def index_with_favorite
    puts "Category index with favorite"
  end
end
