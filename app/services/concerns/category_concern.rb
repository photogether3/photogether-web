module CategoryConcern
  private

  def find_category(category_id, user_id)
    category = Category.where(id: category_id, user_id: user_id)
                      .includes(:posts)
                      .first
    return failure("카테고리를 찾을 수 없습니다.") unless category
    success(category)
  end
end
