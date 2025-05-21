class Collection::Show
  include CollectionConcern

  def initialize(user_id, collection_id)
    @user_id = user_id
    @collection_id = collection_id
  end

  def call
    # 컬렉션 조회
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?

    # 컬렉션 찾음 - 상세 데이터로 변환
    collection = collection_result.data

    # 성공 결과 반환 (collection 객체를 그대로 반환하지 않고 to_detail 메서드 호출 결과를 반환)
    Result.success(collection.to_detail)
  end
end
