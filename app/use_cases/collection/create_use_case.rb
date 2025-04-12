class Collection::CreateUseCase < BaseUseCase
  def initialize(user_id, params)
    @user_id = user_id
    @category_id = params[:categoryId]
    @title = params[:title]
  end

  def call
    return failure("제목을 입력해 주세요.") if @title.blank?

    category = Category.find_by(id: @category_id)
    return failure("카테고리를 찾을 수 없습니다.") unless category

    Collection.create!(
      title: @title,
      category_id: @category_id,
      user_id: @user_id,
      type: "DEFAULT"
    )

    success
  end
end
