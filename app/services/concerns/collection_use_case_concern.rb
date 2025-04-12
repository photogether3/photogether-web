module CollectionUseCaseConcern
  private

  def find_collection(collection_id, user_id)
    collection = Collection.where(id: collection_id, user_id: user_id)
                          .includes(:category, posts: [ :image_attachment ])
                          .first
    return failure("사진첩을 찾을 수 없습니다.") unless collection
    success(collection)
  end
end
