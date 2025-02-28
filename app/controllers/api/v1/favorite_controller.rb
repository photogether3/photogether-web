class Api::V1::FavoriteController < Api::ApplicationApiController
  def index
    puts "Favorite index"
  end

  def creates_or_updates
    puts "Favorite create or update"
  end
end
