module Collections
  class UsersDefaultCreationStrategy
    def initialize(user_id)
      @user_id = user_id
    end

    def create
      Collections.create!([
        { user_id: @user_id, category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { user_id: @user_id, category_id: nil, type: "TRASH", title: "휴지통" }
      ])
    end
  end
end
