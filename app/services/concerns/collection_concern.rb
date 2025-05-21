module CollectionConcern
  private

  def find_collection(collection_id, user_id)
    collection = Collection.where(id: collection_id, user_id: user_id)
                          .includes(:category, posts: [ :image_attachment ])
                          .first
    return Result.failure("사진첩을 찾을 수 없습니다.") unless collection
    Result.success(collection)
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
