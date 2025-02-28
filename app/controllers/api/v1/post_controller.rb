class Api::V1::PostController < Api::ApplicationApiController
  def index
    puts "Post index"
  end

  def show
    puts "Post show"
  end

  def create
    puts "Post create"
  end

  def update
    puts "Post update"
  end

  def change_collection
    puts "Post change collection"
  end

  def destroys
    puts "Post destroys"
  end
end
