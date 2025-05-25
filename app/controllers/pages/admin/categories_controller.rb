class Pages::Admin::CategoriesController < Pages::AdminController
  def index
    categories = Category.order(created_at: :desc)
    render Pages::Admin::Categories::Index.new(categories: categories)
  end

  def new
    category = Category.new
    render Pages::Admin::Categories::New.new(category: category)
  end

  def create
    category_params = params.require(:category).permit(:name)
    result = Admin::Category::Create.new(category_params).call

    puts result.inspect

    if result.success?
      redirect_to admin_categories_path, status: :see_other
    else
      flash[:alert] = result.error_message
      redirect_to admin_categories_new_path, category: category_params
    end
  end

  def destroy
    category = Category.find_by(id: params[:id])

    if category.nil?
      flash[:alert] = "카테고리를 찾을 수 없습니다."
      redirect_to admin_categories_path, status: :see_other
    end

    if category.destroy
      flash[:notice] = "카테고리를 삭제하였습니다."
      redirect_to admin_categories_path, status: :see_other
    else
      flash[:alert] = "카테고리 삭제에 실패하였습니다."
      redirect_to admin_categories_path, status: :see_other
    end
  end
end
