class Collection::Update
  include CollectionConcern

  def initialize(user_id, collection_id, params)
    @user_id = user_id
    @collection_id = collection_id
    @title = params[:title]
    @category_id = params[:categoryId]
  end

  def call
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?

    collection = collection_result.data
    return Result.failure("수정할 수 없는 사진첩입니다.") if collection.type != "DEFAULT"

    return Result.failure("제목을 입력해 주세요.") if @title.blank?

    category_result = find_category(@category_id)
    return category_result if category_result.failure?

    if collection.update(
      title: @title,
      category_id: category_result.data.id
    )
      Result.success(message: "사진첩이 업데이트되었어요.", collection: collection)
    else
      Result.failure("사진첩 업데이트에 실패했습니다: #{collection.errors.full_messages.join(', ')}")
    end
  end
end
