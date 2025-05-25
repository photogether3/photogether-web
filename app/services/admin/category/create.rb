class Admin::Category::Create
  def initialize(params)
    @name = params[:name]
  end

  def call
    return Result.failure("카테고리명을 입력해 주세요") unless @name.present?

    category = Category.new(name: @name)

    if category.save
      Result.success("카테고리가 생성되었습니다.")
    else
      Result.failure("카테고리 생성에 실패하였습니다.")
    end
  end
end
