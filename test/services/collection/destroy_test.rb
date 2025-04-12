# test/services/collection/destroy_test.rb
require "test_helper"

class Collection::DestroyTest < ActiveSupport::TestCase
  setup do
    # 테스트 사용자 생성
    @user = User.create!(
      email_address: "collection_destroy_test@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "컬렉션삭제테스트",
      is_email_verified: true,
      role_id: 1
    )

    # 테스트 카테고리 생성
    @category = Category.create!(name: "테스트 카테고리")

    # 테스트 컬렉션 생성
    @collection = Collection.create!(
      title: "삭제될 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 테스트 게시물 생성
    @post1 = Post.create!(
      title: "테스트 게시물 1",
      content: "테스트 내용 1",
      user_id: @user.id,
      collection_id: @collection.id
    )

    @post2 = Post.create!(
      title: "테스트 게시물 2",
      content: "테스트 내용 1",
      user_id: @user.id,
      collection_id: @collection.id
    )

    # 다른 사용자 생성
    @other_user = User.create!(
      email_address: "other_user@example.com",
      password: "Password1!",
      password_confirmation: "Password1!",
      nickname: "다른사용자",
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
  end

  test "컬렉션이 성공적으로 삭제되고 게시물은 휴지통으로 이동한다" do
    # 실행 전 게시물 수 확인
    assert_equal 2, @collection.posts.count

    # 서비스 실행
    result = Collection::Destroy.new(@user.id, @collection.id).call

    # 결과 확인
    assert result.success?
    assert_equal "사진첩이 삭제되었어요.", result.data[:message]

    # 컬렉션이 삭제되었는지 확인
    assert_nil Collection.find_by(id: @collection.id)

    # 휴지통 컬렉션 확인
    trash = Collection.find_by(user_id: @user.id, type: "TRASH")
    assert_not_nil trash

    # 게시물이 휴지통으로 이동했는지 확인
    assert_equal 2, trash.posts.count
    assert_includes trash.posts.pluck(:id), @post1.id
    assert_includes trash.posts.pluck(:id), @post2.id
  end

  test "게시물이 없는 컬렉션도 성공적으로 삭제된다" do
    # 게시물 없는 빈 컬렉션 생성
    empty_collection = Collection.create!(
      title: "빈 컬렉션",
      category_id: @category.id,
      user_id: @user.id,
      type: "DEFAULT"
    )

    # 서비스 실행
    result = Collection::Destroy.new(@user.id, empty_collection.id).call

    # 결과 확인
    assert result.success?
    assert_equal "사진첩이 삭제되었어요.", result.data[:message]

    # 컬렉션이 삭제되었는지 확인
    assert_nil Collection.find_by(id: empty_collection.id)
  end

  test "존재하지 않는 컬렉션 ID로 삭제 시도 시 실패한다" do
    non_existent_id = 99999

    # 서비스 실행
    result = Collection::Destroy.new(@user.id, non_existent_id).call

    # 결과 확인
    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message
  end

  test "다른 사용자의 컬렉션은 삭제할 수 없다" do
    # 다른 사용자의 컬렉션 삭제 시도
    result = Collection::Destroy.new(@user.id, @other_collection.id).call

    # 결과 확인
    assert result.failure?
    assert_equal "사진첩을 찾을 수 없습니다.", result.error_message

    # 컬렉션이 여전히 존재하는지 확인
    assert_not_nil Collection.find_by(id: @other_collection.id)
  end

  test "이미 휴지통 컬렉션이 있는 경우 기존 휴지통을 사용한다" do
    # 미리 휴지통 생성
    existing_trash = Collection.create!(
      title: "휴지통",
      category_id: @category.id,
      user_id: @user.id,
      type: "TRASH"
    )

    # 서비스 실행
    result = Collection::Destroy.new(@user.id, @collection.id).call

    # 결과 확인
    assert result.success?

    # 게시물이 기존 휴지통으로 이동했는지 확인
    assert_equal 2, existing_trash.reload.posts.count
  end
end
