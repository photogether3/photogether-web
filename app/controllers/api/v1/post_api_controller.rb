class Api::V1::PostApiController < Api::ApplicationApiController
  include Api::PaginationRenderer
  before_action :authenticate_user!

  def index
    result = Post::Index.new(@current_user.id, params[:collectionId]).call
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
    collection = get_collection_or_fail
    posts = get_post_group

    posts.update_all(collection_id: collection.id)
    render json: { message: "게시물이 이동되었습니다." }, status: :ok
  end

  def destroys
    posts = get_post_group
    trash_collection = Collection.find_or_create_trash_for(@current_user)

    posts.update_all(collection_id: trash_collection.id)
    render json: { message: "게시물이 휴지통으로 이동되었습니다." }, status: :ok
  end

  private

    # 사진첩을 조회하고 없으면 예외를 발생시킵니다.
    def get_collection_or_fail
      collection = Collection.find_by(id: params[:collectionId], user_id: @current_user.id)
      raise ActiveRecord::RecordNotFound, "사진첩을 찾을 수 없습니다." unless collection
      collection
    end

    # 게시물을 조회하고 없으면 예외를 발생시킵니다.
    def get_post_or_fail
      post = Post.find_by(id: params[:id], user_id: @current_user.id)
      raise ActiveRecord::RecordNotFound, "게시물을 찾을 수 없습니다." unless post
      post
    end

    # 게시물 그룹을 조회하고 없으면 예외를 발생시킵니다.
    def get_post_group
      post_ids = params[:postIds] || []
      posts = Post.where(id: post_ids)
      raise ActiveRecord::RecordNotFound, "게시물 그룹을 찾을 수 없습니다." if posts.empty?
      posts
    end

    # 메타데이터 문자열을 파싱합니다.
    def parse_metadata_string
      begin
        JSON.parse(params[:metadataStringify] || "[]")
      rescue JSON::ParserError => e
        Rails.logger.error("메타데이터 파싱 오류: #{e.message}")
        raise CustomError, "메타데이터 형식이 올바르지 않습니다."
      end
    end
end
