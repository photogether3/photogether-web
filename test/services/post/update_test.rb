require "test_helper"

class Post::UpdateTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "post_update_test@example.com",
      password: "Password1!",
      nickname: "포스트수정테스트",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 및 컬렉션 생성
    @category = Category.create!(name: "테스트 카테고리")
    @collection = Collection.create!(
      title: "테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 테스트 게시물 생성
    @post = Post.create!(
      title: "기존 제목",
      content: "기존 내용",
      user_id: @user.id,
      collection_id: @collection.id
    )

    # 테스트 메타데이터 추가
    @post.post_metadata.create!(content: "원본 메타데이터", is_public: true, has_link: false)
  end

  test "게시물을 성공적으로 업데이트한다" do
    params = {
      title: "수정된 제목",
      content: "수정된 내용",
      metadataList: [
        {
          "content" => "수정된 메타데이터",
          "isPublic" => true,
          "hasLink" => false
        },
        {
          "content" => "새 메타데이터",
          "isPublic" => false,
          "hasLink" => true
        }
      ]
    }

    result = Post::Update.new(@user.id, @post.id, params).call
    puts result.inspect

    # 결과 확인
    assert result.success?

    # 게시물이 업데이트되었는지 확인
    @post.reload
    assert_equal "수정된 제목", @post.title
    assert_equal "수정된 내용", @post.content

    # 메타데이터가 업데이트되었는지 확인
    assert_equal 2, @post.post_metadata.count

    # 메타데이터 내용 확인
    contents = @post.post_metadata.pluck(:content)
    assert_includes contents, "수정된 메타데이터"
    assert_includes contents, "새 메타데이터"

    # public/private 확인
    private_metadata = @post.post_metadata.find_by(is_public: false)
    puts private_metadata.inspect
    assert_equal "새 메타데이터", private_metadata.content
    assert private_metadata.has_link
  end

  test "존재하지 않는 게시물 업데이트 시도 시 실패한다" do
    params = {
      title: "수정된 제목",
      content: "수정된 내용"
    }

    result = Post::Update.new(@user.id, 9999, params).call

    assert result.failure?
    assert_equal "게시물을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 게시물은 업데이트할 수 없다" do
    # 다른 사용자 생성
    other_user = User.create!(
      email_address: "other_user@example.com",
      password: "Password1!",
      nickname: "다른사용자",
      is_email_verified: true,
      role_id: 1
    )

    params = {
      title: "수정된 제목",
      content: "수정된 내용"
    }

    result = Post::Update.new(other_user.id, @post.id, params).call

    assert result.failure?
    assert_equal "게시물을 찾을 수 없습니다.", result.error_message
  end
end
