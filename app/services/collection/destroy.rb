class Collection::Destroy
  include CollectionConcern

  def initialize(user_id, collection_id)
    @user_id = user_id
    @collection_id = collection_id
  end

  def call
    # 컬렉션 조회
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?

    collection = collection_result.data

    return Result.failure("기본 제공 사진첩을 삭제할 수 없습니다.") if collection.is_system_collection?

    # 게시물 처리 로직 실행
    handle_posts_before_destroy(collection)

    # 컬렉션 삭제
    if collection.destroy
      Result.success(message: "사진첩이 삭제되었어요.")
    else
      Result.failure("사진첩 삭제에 실패했습니다.")
    end
  end

  private

  # 사진첩 삭제 전 게시물 처리
  def handle_posts_before_destroy(collection)
    # 게시물이 없으면 처리 필요 없음
    return unless collection.posts.exists?

    # 휴지통 컬렉션 찾거나 생성
    trash_collection = find_or_create_trash_for(@user_id)

    # 게시물을 휴지통으로 이동
    collection.posts.update_all(collection_id: trash_collection.id)
  end
end
