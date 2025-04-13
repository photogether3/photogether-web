# test/services/post/destroys_test.rb
require "test_helper"

class Post::DestroysTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "destroys_test@example.com",
      password: "Password1!",
      nickname: "삭제테스트사용자",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 생성 - 일반 컬렉션
    @collection = Collection.create!(
      title: "테스트 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 테스트 게시물 생성
    @post1 = Post.create!(
      title: "첫 번째 게시물",
      content: "첫 번째 내용",
      user_id: @user.id,
      collection_id: @collection.id
    )

    @post2 = Post.create!(
      title: "두 번째 게시물",
      content: "두 번째 내용",
      user_id: @user.id,
      collection_id: @collection.id
    )

    @post3 = Post.create!(
      title: "세 번째 게시물",
      content: "세 번째 내용",
      user_id: @user.id,
      collection_id: @collection.id
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_destroys_test@example.com",
      password: "Password1!",
      nickname: "다른삭제테스트사용자",
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

  test "여러 게시물을 휴지통으로 이동한다" do
    # 작업 실행
    result = Post::Destroys.new(@user.id, [ @post1.id, @post2.id ]).call

    # 결과 확인
    assert result.success?

    # 휴지통 컬렉션 조회
    trash_collection = Collection.find_by(user_id: @user.id, type: "TRASH")
    assert_not_nil trash_collection, "휴지통 컬렉션이 생성되지 않았습니다."

    # 게시물이 휴지통으로 이동했는지 확인
    @post1.reload
    @post2.reload
    @post3.reload

    assert_equal trash_collection.id, @post1.collection_id, "첫 번째 게시물이 휴지통으로 이동되지 않았습니다."
    assert_equal trash_collection.id, @post2.collection_id, "두 번째 게시물이 휴지통으로 이동되지 않았습니다."
    assert_equal @collection.id, @post3.collection_id, "세 번째 게시물이 잘못 이동되었습니다."
  end

  test "존재하지 않는 게시물 ID로 호출 시 실패한다" do
    result = Post::Destroys.new(@user.id, [ 999, 1000 ]).call

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 게시물을 이동하려고 시도하면 실패한다" do
    result = Post::Destroys.new(@user.id, [ @other_post.id ]).call
    puts result.inspect

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "비어있는 ID 배열로 호출 시 실패한다" do
    result = Post::Destroys.new(@user.id, []).call

    assert result.failure?
    assert_equal "게시물 그룹을 찾을 수 없습니다.", result.error_message
  end

  test "휴지통이 이미 존재하면 새로 생성하지 않는다" do
    # 먼저 휴지통 생성
    initial_result = Post::Destroys.new(@user.id, [ @post1.id ]).call
    assert initial_result.success?

    # 휴지통 컬렉션 조회
    trash_collection = Collection.find_by(user_id: @user.id, type: "TRASH")
    initial_trash_id = trash_collection.id

    # 두 번째 작업 실행
    second_result = Post::Destroys.new(@user.id, [ @post3.id ]).call
    assert second_result.success?

    # 같은 휴지통을 사용했는지 확인
    updated_trash_collection = Collection.find_by(user_id: @user.id, type: "TRASH")
    assert_equal initial_trash_id, updated_trash_collection.id, "새 휴지통이 생성되었습니다."

    # 모든 게시물이 같은 휴지통에 있는지 확인
    @post1.reload
    @post3.reload

    assert_equal trash_collection.id, @post1.collection_id
    assert_equal trash_collection.id, @post3.collection_id
  end

  test "이미 휴지통에 있는 게시물을 다시 삭제해도 정상 동작한다" do
    # 첫 번째 삭제 작업 실행
    first_result = Post::Destroys.new(@user.id, [ @post1.id ]).call
    assert first_result.success?

    # 휴지통 컬렉션 조회
    trash_collection = Collection.find_by(user_id: @user.id, type: "TRASH")

    # 같은 게시물 다시 삭제 시도
    second_result = Post::Destroys.new(@user.id, [ @post1.id ]).call
    assert second_result.success?, "이미 휴지통에 있는 게시물 삭제 시 실패했습니다."

    # 여전히 휴지통에 있는지 확인
    @post1.reload
    assert_equal trash_collection.id, @post1.collection_id
  end
end
