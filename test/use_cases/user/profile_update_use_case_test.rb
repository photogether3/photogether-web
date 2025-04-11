require "test_helper"

class User::ProfileUpdateUseCaseTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup do
    @default_nickname = "tester"
    @default_bio = "helloworld"
    @user = User.create!(
      email_address: "test@example.com",
      password: "Password1!",
      is_email_verified: false,
      nickname: @default_nickname,
      bio: @default_bio,
      role_id: 1
    )
  end

  test "정상적으로 사용자 정보를 업데이트한다." do
    file = fixture_file_upload(
      Rails.root.join("test/fixtures/files/test_img.jpg"),
      "image/jpeg"
    )
    update_nickname = "UpdatedNickname"
    update_bio = "update bio"
    params = {
      nickname: update_nickname,
      bio: update_bio,
      file: file
    }
    result = User::ProfileUpdateUseCase.new(@user, params).call

    assert result.success?
    @user.reload
    assert_equal update_nickname, @user.nickname
    assert_equal update_bio, @user.bio
    assert @user.image.attached?
  end

  test "닉네임만 넘기면 닉네임만 업데이트한다." do
    update_nickname = "UpdateNickname"
    result = User::ProfileUpdateUseCase.new(@user, nickname: update_nickname).call

    assert result.success?
    @user.reload
    assert_equal update_nickname, @user.nickname
    assert_equal @default_bio, @user.bio
    refute @user.image.attached?, "이미지가 첨부되어 있으면 안됩니다"
  end

  test "자기소개글만 넘기면 자기소개글만 업데이트한다." do
    update_bio = "helloworld2"
    result = User::ProfileUpdateUseCase.new(@user, bio: update_bio).call

    assert result.success?
    @user.reload
    assert_equal @default_nickname, @user.nickname
    assert_equal update_bio, @user.bio
    refute @user.image.attached?, "이미지가 첨부되어 있으면 안됩니다"
  end

  test "이미지만 넘기면 이미지만 업데이트한다." do
    test_image = fixture_file_upload(
      Rails.root.join("test/fixtures/files/test_img.jpg"),
      "image/jpeg"
    )
    result = User::ProfileUpdateUseCase.new(@user, file: test_image).call

    assert result.success?
    @user.reload
    assert_equal @default_nickname, @user.nickname
    assert_equal @default_bio, @user.bio
    assert @user.image.attached?
  end
end
