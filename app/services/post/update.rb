class Post::Update
  include PostConcern
  include MetadataConcern

  def initialize(user_id, post_id, params)
    @user_id = user_id
    @post_id = post_id
    @title = params[:title]
    @content = params[:content]
    @metadata_list = params[:metadataList] || []
  end

  def call
    # 게시물 조회
    post_result = find_post(@post_id, @user_id)
    return post_result if post_result.failure?

    post = post_result.data

    # 게시물 업데이트
    Post.transaction do
      # 제목이 없고 메타데이터가 있는 경우 메타데이터에서 제목 추출
      if @title.blank?
        @title = extract_title_from_metadata(@metadata_list)
      end

      # 게시물 업데이트
      post.update!(
        title: @title.presence || "",
        content: @content.presence || ""
      )

      # 기존 메타데이터 삭제
      post.post_metadata.delete_all

      # 새로운 메타데이터 추가
      create_post_metadata(post, @metadata_list)
    end

    # 성공 결과 반환
    Result.success
  end
end
