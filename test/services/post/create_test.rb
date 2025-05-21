# test/services/post/create_test.rb
require "test_helper"

class Post::CreateTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "post_create_test@example.com",
      password: "Password1!",
      nickname: "포스트생성테스트",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 생성
    @collection = Collection.create!(
      title: "테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 테스트 이미지 파일 준비
    @file = fixture_file_upload(
      Rails.root.join("test", "fixtures", "files", "test_img.jpg"),
      "image/jpeg"
    )
  end

  test "유효한 데이터로 게시물을 성공적으로 생성한다" do
    # 서비스 실행
    params = {
      collectionId: @collection.id,
      title: "테스트 게시물",
      content: "테스트 내용입니다.",
      file: @file,
      metadataStringify: '[{"content":"서울에서 촬영","isPublic":true,"hasLink":false},{"content":"SONY 카메라로 촬영","isPublic":true,"hasLink":true}]'
    }

    result = Post::Create.new(@user.id, params).call

    puts result.inspect

    # 결과 확인
    assert result.success?

    # 실제 게시물이 생성되었는지 확인
    post = Post.last
    assert_equal "테스트 게시물", post.title
    assert_equal "테스트 내용입니다.", post.content
    assert_equal @collection.id, post.collection_id
    assert_equal @user.id, post.user_id

    # 메타데이터가 생성되었는지 확인
    assert_equal 2, post.post_metadata.count

    # 첫 번째 메타데이터 확인
    첫번째_메타데이터 = post.post_metadata.first
    assert_equal "서울에서 촬영", 첫번째_메타데이터.content
    assert 첫번째_메타데이터.is_public
    assert_not 첫번째_메타데이터.has_link

    # 두 번째 메타데이터 확인
    두번째_메타데이터 = post.post_metadata.last
    assert_equal "SONY 카메라로 촬영", 두번째_메타데이터.content
    assert 두번째_메타데이터.is_public
    assert 두번째_메타데이터.has_link
  end

  test "파일이 없으면 실패한다" do
    params = {
      collectionId: @collection.id,
      title: "테스트 게시물",
      content: "테스트 내용입니다."
      # 파일 없음
    }

    result = Post::Create.new(@user.id, params).call

    assert result.failure?
    assert_equal "파일은 필수값 입니다.", result.error_message
  end

  test "존재하지 않는 컬렉션으로 생성 시도 시 실패한다" do
    params = {
      collectionId: 9999, # 존재하지 않는 ID
      title: "테스트 게시물",
      content: "테스트 내용입니다.",
      file: @file
    }

    result = Post::Create.new(@user.id, params).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "메타데이터 형식이 잘못된 경우 실패한다" do
    params = {
      collectionId: @collection.id,
      title: "테스트 게시물",
      content: "테스트 내용입니다.",
      file: @file,
      metadataStringify: "invalid json format"
    }

    result = Post::Create.new(@user.id, params).call

    assert result.failure?
    assert_equal "메타데이터 형식이 올바르지 않습니다.", result.error_message
  end
end
