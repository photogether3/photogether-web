class Post::Create
  include CollectionConcern
  include MetadataConcern

  def initialize(user_id, params)
    @user_id = user_id
    @collection_id = params[:collectionId]
    @title = params[:title]
    @content = params[:content]
    @file = params[:file]
    @metadata_string = params[:metadataStringify]
  end

  def call
    # 파일 필수 검증
    return Result.failure("파일은 필수값 입니다.") if @file.blank?

    # 컬렉션 조회
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?

    # 메타데이터 파싱
    begin
      metadata_list = parse_metadata_string(@metadata_string)
    rescue => e
      Rails.logger.error("메타데이터 파싱 오류: #{e.message}")
      return Result.failure("메타데이터 형식이 올바르지 않습니다.")
    end

    Post.transaction do
      # 제목이 없고 메타데이터가 있는 경우 메타데이터에서 제목 추출
      if @title.blank?
        @title = extract_title_from_metadata(metadata_list)
      end

      # 새 게시물 생성
      post = Post.new(
        title: @title.presence || "제목 없음",
        content: @content.presence || "내용 없음",
        user_id: @user_id,
        collection_id: collection_result.data.id
      )

      # 이미지 첨부
      post.image.attach(@file) if @file.present?
      post.save!

      # 메타데이터 생성
      create_post_metadata(post, metadata_list)

      # 비동기 작업 예약
      if post.image.attached?
        ProcessImageVariantsJob.perform_later(post.id)
      end
    end

    # 성공 결과 반환
    Result.success
  end
end
