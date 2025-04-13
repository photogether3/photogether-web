class Api::V1::PostApiController < Api::ApplicationApiController
  include Api::PaginationRenderer
  before_action :authenticate_user!

  def index
    puts params
    result = Post::Index.new(@current_user.id, params).call
    render_result(result)
  end

  def show
    post = Post.find_by(id: params[:id], user_id: @current_user.id)
    render json: post.to_detail, status: :ok
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
