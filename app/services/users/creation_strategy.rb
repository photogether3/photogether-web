module Users
  class CreationStrategy
    def initialize(params)
      @email = params[:email]
      @password = params[:password]
      @password_confirmation = params[:password]
      @nickname = BaseUtil.generate_random_nickname
      @role_id = 1
    end

    def policy(policy_strategy)
      @policy_strategy = policy_strategy
    end

    def create
      @policy_strategy.validate # .. 요런 느낌 ?

      # 사용자 생성
      user = User.create!(
        email_address: @email,
        password: @password,
        password_confirmation: @password_confirmation,
        nickname: @nickname,
        role_id: @role_id
      )

      collection_creation_strategy = Collections::CreationStrategy.new(user.id)
      Collection.create_with(collection_creation_strategy)
    end
  end
end
