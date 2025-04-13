class Api::V1::PostApiController < Api::ApplicationApiController
  include Api::PaginationRenderer
  before_action :authenticate_user!

  def index
    collection = get_collection_or_fail
    pagination = pagination_params

    posts = Post
      .where(user_id: @current_user.id, collection_id: collection.id)
      .order(pagination[:sort_by] => pagination[:sort_order])
      .includes(:collection, :post_metadata)
      .page(pagination[:page]).per(pagination[:per_page])

    response_data = paginated_response_for(posts) do |post|
      post_with_image_urls(post)
    end

    render json: response_data, status: :ok
  end

  def show
    post = get_post_or_fail
    render json: post_with_image_urls(post), status: :ok
  end

  def create
    result = Post::Create.new(@current_user.id, params).call
    render_result(result)
  end

  def update
    title, content = get_title_and_content
    post = get_post_or_fail

    metadata_list = params[:metadataList] || []
    post.update_with_metadata(title, content, metadata_list)
    render json: { message: "게시물이 수정되었습니다." }, status: :ok
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

    # 제목과 내용을 파라미터에서 가져옵니다.
    def get_title_and_content
      [ params[:title], params[:content] ]
    end

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

    # 이미지 URL을 생성하는 헬퍼 메서드
    def post_with_image_urls(post)
      # 기본 데이터 가져오기
      post_data = post.to_detail

      # 이미지 URL 추가
      if post.image.attached?
        variants = post.image_variants

        post_data.merge!(
          image_url: url_for(post.image), # 원본 이미지 URL
          images: {
            blur: variants[:blur] ? url_for(variants[:blur]) : nil, # 너비 30px 축소 이미지 URL
            grid: variants[:grid] ? url_for(variants[:grid]) : nil, # 너비 300px 리스트 이미지 URL
            detail: variants[:detail] ? url_for(variants[:detail]) : nil # 너비 700px 상세조회용 이미지 URL
          }
        )
      else
        post_data.merge!(
          image_url: nil,
          images: { blur: nil, grid: nil, detail: nil }
        )
      end

      post_data
    end
end
