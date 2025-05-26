class Views::Pages::Admin::Users::Posts::Show < Views::Base
  def initialize(post:)
    @post = post
    puts "======================================="
    puts @post.inspect
    puts "======================================="
  end

  def view_template
    render Views::Shared::Components::Modal.new(title: "게시물 상세") do
      div do
        "hello world"
      end
    end
  end
end
