class Admin::PostsController < Admin::AdminController
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]

  def index
    page     = params[:page] ||= 1
    per_page = 12
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""
    filter_by = params[:filter_by] ||= ""

    # 필요한 관계만 미리 로드
    @posts = Post.includes(:user, collection: :category, image_attachment: :blob)
    @posts = @posts.where("posts.title LIKE :q OR posts.content LIKE :q", q: "%#{keyword}%") if keyword.present?

    # 필터링 - 카테고리 ID로 필터링할 경우
    if filter_by.present?
      @posts = @posts.joins(collection: :category).where(collections: { category_id: filter_by })
    end

    # 정렬 - 존재하는 필드만 사용
    order_by = "created_at" unless [ "created_at", "updated_at", "title" ].include?(order_by)
    @posts = @posts.order("posts.#{order_by} #{order}")

    @posts = @posts.page(page).per(per_page)

    # 필터링을 위한 카테고리 목록 가져오기
    @categories = Category.all.order(:name)
  end

  def show
  end

  def new
    @post = Post.new
    @users = User.order(:nickname)
    # 컬렉션 필드는 사용자 선택에 따라 자동으로 설정되므로 폼에서 제거
  end

  # TODO:
  # 1. 생성 이후 게시물 갱신 안되는 부분 수정
  # 2. 메타데이터 저장시 채크박스 on을 직접 변환하는 작업 수정
  # -> 화면에서 미리 value를 변환해서 가져오기
  def create
    @post = Post.new(post_params.except(:collection_id, :image, :metadata))

    # 선택된 사용자의 미분류 컬렉션 찾기
    if @post.user_id.present?
      uncategorized_collection = Collection.find_by(user_id: @post.user_id, type: "UNCATEGORIZED")

      # 미분류 컬렉션이 없으면 생성
      if uncategorized_collection.nil?
        uncategorized_collection = Collection.create!(
          user_id: @post.user_id,
          type: "UNCATEGORIZED",
          title: "미분류"
        )
      end

      # 컬렉션 ID 설정
      @post.collection_id = uncategorized_collection.id
    end

    # 메타데이터 준비
    metadata_list = process_metadata

    # 이미지 파일
    file = params[:post][:image]

    begin
      # 트랜잭션 내에서 처리
      Post.transaction do
        # 기본 정보 저장
        @post.save!

        # 이미지 첨부
        @post.image.attach(file) if file.present?

        # 메타데이터 저장
        if metadata_list.present?
          metadata_list.each do |metadata|
            PostMetadatum.create!(
              post_id: @post.id,
              content: metadata[:content],
              is_public: metadata[:isPublic],
              has_link: metadata[:hasLink],
              rank: 1 # 순서 필드가 있다면 사용
            )
          end
        end
      end

      redirect_to admin_posts_path, notice: "게시물이 성공적으로 생성되었습니다."
    rescue => e
      @users = User.order(:nickname)
      flash.now[:alert] = "게시물 생성 중 오류가 발생했습니다: #{e.message}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.order(:nickname)
    @metadata = @post.post_metadata
    # 컬렉션 필드는 사용자 선택에 따라 자동으로 설정되므로 폼에서 제거
  end

  def update
    # 원래 사용자와 다른 사용자로 변경되었는지 확인
    user_changed = params[:post][:user_id].present? && @post.user_id.to_s != params[:post][:user_id]

    # 사용자가 변경된 경우, 새 사용자의 미분류 컬렉션으로 변경
    if user_changed
      new_user_id = params[:post][:user_id]
      uncategorized_collection = Collection.find_by(user_id: new_user_id, type: "UNCATEGORIZED")

      # 미분류 컬렉션이 없으면 생성
      if uncategorized_collection.nil?
        uncategorized_collection = Collection.create!(
          user_id: new_user_id,
          type: "UNCATEGORIZED",
          title: "미분류"
        )
      end

      # 컬렉션 ID 설정 (params에 직접 추가하지 않고 별도 변수에 저장)
      new_collection_id = uncategorized_collection.id
    end

    # 이미지 파일
    file = params[:post][:image]

    # 메타데이터 준비
    metadata_list = process_metadata

    begin
      # 트랜잭션 내에서 처리
      Post.transaction do
        # 기본 정보 업데이트 (collection_id는 별도 처리)
        update_params = post_params.except(:collection_id, :image, :metadata)

        # 사용자가 변경된 경우에만 컬렉션 ID도 함께 변경
        update_params[:collection_id] = new_collection_id if user_changed

        # 기본 정보 업데이트
        @post.update!(update_params)

        # 이미지 교체 (기존 이미지가 있다면 자동으로 대체됨)
        @post.image.attach(file) if file.present?

        # 기존 메타데이터 삭제
        @post.post_metadata.destroy_all

        # 새 메타데이터 저장
        if metadata_list.present?
          metadata_list.each do |metadata|
            PostMetadatum.create!(
              post_id: @post.id,
              content: metadata[:content],
              is_public: metadata[:isPublic],
              has_link: metadata[:hasLink],
              rank: 1 # 순서 필드가 있다면 사용
            )
          end
        end
      end

      redirect_to admin_post_path(@post), notice: "게시물이 성공적으로 수정되었습니다."
    rescue => e
      @users = User.order(:nickname)
      @metadata = @post.post_metadata
      flash.now[:alert] = "게시물 수정 중 오류가 발생했습니다: #{e.message}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "게시물이 삭제되었습니다."
  end

  private

  def set_post
    @post = Post.includes(:user, :collection, :post_metadata, image_attachment: :blob)
                .find(params[:id])
  end

  def post_params
    # 이미지와 메타데이터 필드 추가
    params.require(:post).permit(:title, :content, :user_id, :collection_id, :image, metadata: [])
  end

  def process_metadata
    return [] unless params[:post] && params[:post][:metadata].present?

    metadata_list = []

    params[:post][:metadata].each do |item|
      # item이 해시가 아닌 경우(배열 형태로 들어올 수 있음) 건너뛰기
      next unless item.is_a?(ActionController::Parameters) || item.is_a?(Hash)
      # content가 없으면 건너뛰기
      next if item[:content].blank? && item["content"].blank?

      content = item[:content] || item["content"]
      is_public = item[:isPublic] == "1" || item[:isPublic] == "on" ||
                 item["isPublic"] == "1" || item["isPublic"] == "on"
      has_link = item[:hasLink] == "1" || item[:hasLink] == "on" ||
                item["hasLink"] == "1" || item["hasLink"] == "on"

      metadata_list << {
        content: content,
        isPublic: is_public,
        hasLink: has_link
      }
    end

    metadata_list
  end
end
