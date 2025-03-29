class Admin::DashboardController < Admin::AdminController
  def index
    # 사용자 통계
    @users_count = User.count
    @latest_user = User.order(created_at: :desc).first

    # 카테고리 통계
    @categories_count = Category.count
    @top_categories = Category
                        .left_joins(:favorites)
                        .group(:id)
                        .select('categories.*, COUNT(favorites.id) as favorites_count')
                        .order('favorites_count DESC')
                        .limit(2)

    # 게시물 통계
    @posts_count = Post.count
    @recent_posts_count = Post.where('created_at >= ?', 30.days.ago).count
    @posts_per_user = User.count > 0 ? (@posts_count.to_f / User.count).round(1) : 0

    # 최근 가입 회원
    @recent_users = User.order(created_at: :desc).limit(5)

    # 시스템 정보
    @ruby_version = RUBY_VERSION
    @rails_version = Rails.version
    @rails_env = Rails.env
  end
end