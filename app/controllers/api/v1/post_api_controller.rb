class Api::V1::PostApiController < ApiController
  include Api::PaginationRenderer
  before_action :authenticate_user!

  def index
    puts params
    result = Post::Index.new(@current_user.id, params).call
    render_result(result)
  end

  def show
    post = Post.find_by(id: params[:id], user_id: @current_user.id)

    if post.nil?
      return render json: { error: "게시물을 찾을 수 없습니다" }, status: :not_found
    end

    response_data = post.to_detail
    response_data[:prev_post] = post.prev_post_info
    response_data[:next_post] = post.next_post_info

    render json: response_data, status: :ok
  end

  def create
    result = Post::Create.new(@current_user.id, params).call
    render_result(result)
  end

  def update
    result = Post::Update.new(@current_user.id, params[:id], params).call
    render_result(result)
  end

  def change_collection
    result = Post::Move.new(@current_user.id, params[:postIds], params[:collectionId]).call
    render_result(result)
  end

  def destroys
    result = Post::Destroys.new(@current_user.id, params[:postIds]).call
    render_result(result)
  end
end
