class Post::Create
  include CollectionConcern
  include Rails.application.routes.url_helpers

  def initialize(user_id, params)
    @user_id = user_id
    @collection_id = params[:collectionId]
    @title = params[:title]
    @content = params[:content]
    @file = params[:file]
    @metadata_string = params[:metadataStringify] # 메타데이터 JSON 문자열
    @params = params
  end

  def call
    # 파일 필수 검증
    return Result.failure("파일은 필수값 입니다.") if @file.blank?

    # 컬렉션 조회
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?

    # 메타데이터 파싱
    begin
      metadata_list = parse_metadata_string
    rescue => e
      Rails.logger.error("메타데이터 파싱 오류: #{e.message}")
      return Result.failure("메타데이터 형식이 올바르지 않습니다.")
    end

    # 게시물 생성
    begin
      post = Post.new(
        title: @title,
        content: @content,
        user_id: @user_id,
        collection_id: collection_result.data.id
      )

      # 이미지 첨부
      post.image.attach(@file)

      # 저장
      if post.save
        # 메타데이터 생성
        create_post_metadata(post, metadata_list)

        Result.success
      else
        Result.failure("게시물 생성에 실패했습니다: #{post.errors.full_messages.join(', ')}")
      end
    rescue => e
      Rails.logger.error("게시물 생성 오류: #{e.message}")
      Result.failure("게시물 생성에 실패했습니다.")
    end
  end

  private

  # 메타데이터 문자열을 파싱
  def parse_metadata_string
    return [] if @metadata_string.blank?

    JSON.parse(@metadata_string)
  rescue JSON::ParserError => e
    Rails.logger.error("메타데이터 파싱 오류: #{e.message}")
    raise
  end

  # 게시물 메타데이터 생성
  def create_post_metadata(post, metadata_list)
    metadata_list.each do |metadata|
      post.post_metadata.create!(
        content: metadata["content"] || metadata["key"], # content 또는 key 필드 사용
        is_public: metadata["isPublic"] || true,
        has_link: metadata["hasLink"] || false
      )
    end
  end
end
