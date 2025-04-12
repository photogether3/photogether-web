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

  # 사용자의 휴지통 컬렉션을 찾거나 생성
  def find_or_create_trash_for(user_id)
    # 기존 휴지통 찾기
    trash = Collection.find_by(user_id: user_id, type: "TRASH")

    # 없으면 새로 생성
    unless trash
      # 기본 카테고리 찾기 (또는 첫 번째 카테고리)
      category = Category.find_by(name: "기본") || Category.first

      trash = Collection.create!(
        title: "휴지통",
        user_id: user_id,
        category_id: category.id,
        type: "TRASH"
      )
    end

    trash
  end
end
