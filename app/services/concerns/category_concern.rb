module CategoryConcern
  private

  def find_category(category_id)
    category = Category.find_by(id: category_id)
    return Result.failure("카테고리를 찾을 수 없습니다.") unless category
    Result.success(category)
  end
end
