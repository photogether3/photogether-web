class Collection::Create
  include CategoryConcern

  def initialize(user_id, params)
    @user_id = user_id
    @category_id = params[:categoryId] # 이미 여기서 추출됨
    @title = params[:title]
  end

  def call
    return Result.failure("제목을 입력해 주세요.") if @title.blank?

    # @params 대신 @category_id 사용
    result = find_category(@category_id)
    return result if result.failure?

    puts "category: #{result.inspect}"
    category = result.data

    Collection.create!(
      title: @title,
      category: category,
      user_id: @user_id,
      type: "DEFAULT"
    )

    Result.success
  end
end
