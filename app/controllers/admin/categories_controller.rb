class Admin::CategoriesController < Admin::AdminController
  def index
    page     = params[:page] ||= 1
    per_page = 5
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""

    @categories = Category.all
    @categories = @categories.where("name LIKE :q", q: "%#{keyword}%") if keyword.present?
    @categories = @categories.page(page).per(per_page)
    @categories = @categories.order("#{order_by} #{order}")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("category_list", partial: "admin/categories/category_list")
      end
      format.html
    end
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    category_params = params.require(:category).permit(:name)

    puts category_params.inspect

    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.turbo_stream { head :ok }
      else
        @modal_anims = ""
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    category_params = params.require(:category)

    @category = Category.find(params[:id])
    @category.name = category_params[:name]

    respond_to do |format|
      if @category.save
        format.turbo_stream { head :ok }
      else
        @modal_anims = ""
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("category_#{@category.id}"),
          turbo_stream.replace("category_total", partial: "shared/item_total", locals: {
            total_count_id: "category_total",
            total_count: Category.all.count,
            content: "총 카테고리 수"
          })
        ]
      end
    end
  end
end
