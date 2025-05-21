# test/services/post/move_test.rb
require "test_helper"

class Post::MoveTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "move_test@example.com",
      password: "Password1!",
      nickname: "이동테스트사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 두 개 생성
    @source_collection = Collection.create!(
      title: "원본 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    @target_collection = Collection.create!(
      title: "대상 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 테스트 게시물 생성
    @post1 = Post.create!(
      title: "첫 번째 게시물",
      content: "첫 번째 내용",
      user_id: @user.id,
      collection_id: @source_collection.id
    )

    @post2 = Post.create!(
      title: "두 번째 게시물",
      content: "두 번째 내용",
      user_id: @user.id,
      collection_id: @source_collection.id
    )

    @post3 = Post.create!(
      title: "세 번째 게시물",
      content: "세 번째 내용",
      user_id: @user.id,
      collection_id: @source_collection.id
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_move_test@example.com",
      password: "Password1!",
      nickname: "다른이동테스트사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 다른 사용자의 컬렉션 생성
    @other_collection = Collection.create!(
      title: "다른 사용자의 컬렉션",
      category_id: @category.id,
      user_id: @other_user.id,
      type: "DEFAULT"
    )

    # 다른 사용자의 게시물 생성
    @other_post = Post.create!(
      title: "다른 사용자의 게시물",
      content: "다른 사용자의 내용",
      user_id: @other_user.id,
      collection_id: @other_collection.id
    )
  end

  test "여러 게시물을 다른 컬렉션으로 이동한다" do
    # 작업 실행
    result = Post::Move.new(@user.id, [ @post1.id, @post2.id ], @target_collection.id).call

    # 결과 확인
    assert result.success?

    # 게시물이 대상 컬렉션으로 이동했는지 확인
    @post1.reload
    @post2.reload
    @post3.reload

    assert_equal @target_collection.id, @post1.collection_id, "첫 번째 게시물이 이동되지 않았습니다."
    assert_equal @target_collection.id, @post2.collection_id, "두 번째 게시물이 이동되지 않았습니다."
    assert_equal @source_collection.id, @post3.collection_id, "세 번째 게시물이 잘못 이동되었습니다."
  end

  test "존재하지 않는 게시물 ID로 호출 시 실패한다" do
    result = Post::Move.new(@user.id, [ 999, 1000 ], @target_collection.id).call

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "존재하지 않는 컬렉션으로 이동 시도 시 실패한다" do
    result = Post::Move.new(@user.id, [ @post1.id, @post2.id ], 999).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 컬렉션으로 이동 시도 시 실패한다" do
    result = Post::Move.new(@user.id, [ @post1.id, @post2.id ], @other_collection.id).call

    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 게시물을 이동하려고 시도하면 실패한다" do
    result = Post::Move.new(@user.id, [ @other_post.id ], @target_collection.id).call

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "비어있는 ID 배열로 호출 시 실패한다" do
    result = Post::Move.new(@user.id, [], @target_collection.id).call

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "같은 컬렉션으로 이동해도 성공한다" do
    result = Post::Move.new(@user.id, [ @post1.id, @post2.id ], @source_collection.id).call

    assert result.success?

    # 게시물이 여전히 원본 컬렉션에 있는지 확인
    @post1.reload
    @post2.reload

    assert_equal @source_collection.id, @post1.collection_id
    assert_equal @source_collection.id, @post2.collection_id
  end

  test "시스템 컬렉션으로도 이동할 수 있다" do
    # 휴지통 컬렉션 생성
    trash_collection = Collection.create!(
      title: "휴지통",
      user_id: @user.id,
      type: "TRASH"
    )

    result = Post::Move.new(@user.id, [ @post1.id ], trash_collection.id).call

    assert result.success?

    # 게시물이 휴지통으로 이동했는지 확인
    @post1.reload
    assert_equal trash_collection.id, @post1.collection_id
  end
end
