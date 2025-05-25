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
    result = Admin::Category::Create.new(category_params).call

    puts result.inspect

    if result.success?
      redirect_to admin_categories_path, status: :see_other
    else
      flash[:alert] = result.error_message
      redirect_to admin_categories_new_path, category: category_params
    end
  end

  def edit
    category = Category.find_by(id: params[:id])

    if category.nil?
      flash[:alert] = "카테고리를 찾을 수 없습니다."
      redirect_to admin_categories_path, status: :see_other
    end

    render Pages::Admin::Categories::Edit.new(category: category)
  end

  def update
    category = Category.find_by(id: params[:id])

    if category.nil?
      flash[:alert] = "카테고리를 찾을 수 없습니다."
      redirect_to admin_categories_path, status: :see_other
    end

    category.name = category_params[:name]

    if category.save
      flash[:notice] = "카테고리가 수정되었습니다."
      redirect_to admin_categories_path, status: :see_other
    else
      flash[:alert] = "카테고리 수정 중 문제가 발생하였습니다."
      redirect_to "/admin/categories/#{category.id}/edit", status: :see_other
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

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
