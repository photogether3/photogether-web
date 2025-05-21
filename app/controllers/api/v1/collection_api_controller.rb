class Api::V1::CollectionApiController < Api::ApplicationApiController
  include Api::PaginationRenderer

  before_action :authenticate_user!

  def index
    result = Collection::Index.new(@current_user.id, params).call
    render_result(result)
  end

  def show
    result = Collection::Show.new(@current_user.id, params[:id]).call
    render_result(result)
  end

  def create
    result = Collection::Create.new(@current_user.id, params).call
    render_result(result)
  end

  def update
    result = Collection::Update.new(@current_user.id, params[:id], params).call
    render_result(result)
  end

  def destroy
    result = Collection::Destroy.new(@current_user.id, params[:id]).call
    render_result(result)
  end
end
