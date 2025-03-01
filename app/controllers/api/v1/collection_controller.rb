class Api::V1::CollectionController < Api::ApplicationApiController
  before_action :authenticate_user!
  before_action :get_category_or_fail, only: [ :create, :update ]
  before_action :get_collection_or_fail, only: [ :show, :update, :destroy ]

  def index
    puts "Collection index"
  end

  def show
    puts "Collection show"
  end

  def create
    Collection.create!(
      title: params[:title],
      category_id: @category.id,
      user_id: @current_user.id,
      type: "DEFAULT"
    )

    render json: { message: "사진첩이 생성되었어요." }, status: :ok
  end

  def update
    raise CustomError, "수정할 수 없는 사진첩입니다." if @collection.type != "DEFAULT"

    @collection.update!(
      title: params[:title],
      category_id: @category.id
    )

    render json: { message: "사진첩이 업데이트되었어요." }, status: :ok
  end

  def destroy
    # 게시물을 가지고 있는 사진첩은 삭제 이전에
    # 사용자의 휴지통 사진첩으로 게시물을 이동시키는 작업이 필요
    @collection.destroy

    render json: { message: "사진첩이 삭제되었어요." }, status: :ok
  end

  private

  # 카테고리를 조회하고 없으면 예외를 발생시킵니다.
  def get_category_or_fail
    @category = Category.find_by(id: params[:categoryId])
    raise ActiveRecord::RecordNotFound, "카테고리를 찾을 수 없습니다." unless @category
  end

  # 사진첩을 조회하고 없으면 예외를 발생시킵니다.
  def get_collection_or_fail
    @collection = Collection.find_by(id: params[:id], user_id: @current_user.id)
    raise ActiveRecord::RecordNotFound, "사진첩을 찾을 수 없습니다." unless @collection
  end
end
