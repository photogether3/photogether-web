class Pages::Admin::CategoriesController < Pages::AdminController
  def index
    categories = Category.order(created_at: :desc)
    render Pages::Admin::Categories::Index.new(categories: categories)
  end
end
