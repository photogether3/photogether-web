class Admin::PostsController < Admin::AdminController
  def index
    page     = params[:page] ||= 1
    per_page = 5
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""
    filter_by = params[:filter_by] ||= ""

    @posts = Post.includes(:user, :category, images_attachments: :blob)
    @posts = @posts.where("title LIKE :q OR content LIKE :q", q: "%#{keyword}%") if keyword.present?
    @posts = @posts.where(category_id: filter_by) if filter_by.present?
    @posts = @posts.page(page).per(per_page)
    @posts = @posts.order("#{order_by} #{order}")

    @categories = Category.all.order(:name)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("post_list", partial: "admin/posts/post_list")
      end
      format.html
    end
  end

  def show
    @post = Post.includes(:user, :category, comments: :user, images_attachments: :blob).find(params[:id])
  end

  def new
    @post = Post.new
    @categories = Category.all.order(:name)
  end

  def create
    post_params = params.require(:post).permit(:title, :content, :user_id, :category_id, images: [])

    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.turbo_stream { head :ok }
      else
        @categories = Category.all.order(:name)
        @modal_anims = ""
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @post = Post.find(params[:id])
    @categories = Category.all.order(:name)
  end

  def update
    post_params = params.require(:post).permit(:title, :content, :category_id, images: [])

    @post = Post.find(params[:id])

    # 이미지 처리 - remove_images 파라미터가 있으면 기존 이미지 삭제
    if params[:remove_images].present?
      @post.images.purge
    end

    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream { head :ok }
      else
        @categories = Category.all.order(:name)
        @modal_anims = ""
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.turbo_stream do
        @posts = Post.includes(:user, :category, images_attachments: :blob)
        render turbo_stream: [
          turbo_stream.remove("post_#{@post.id}"),
          turbo_stream.replace("post_total", partial: "shared/item_total", locals: {
            total_count_id: "post_total",
            total_count: Post.count,
            content: "총 게시물 수"
          })
        ]
      end
    end
  end
end
