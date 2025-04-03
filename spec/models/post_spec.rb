require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, user: user) }
  let(:image_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_img.jpg') }
  let(:metadata_list) { [ { "content" => "테스트 메타데이터", "isPublic" => true, "hasLink" => false } ] }

  describe "이미지 처리" do
    context "이미지 변환" do
      it "원본 이미지와 썸네일을 함께 생성한다" do
        # 테스트 이미지 파일 생성
        file = fixture_file_upload(image_path, 'image/jpeg')

        # 게시물 생성
        post = Post.create_with_metadata(
          user.id,
          collection.id,
          "테스트 게시물",
          "테스트 내용",
          metadata_list,
          file
        )

        # 원본 이미지가 첨부되었는지 확인
        expect(post.image).to be_attached

        # 썸네일이 생성되었는지 확인
        expect(post.image.variant(:thumbnail)).to be_present

        # 썸네일 크기 확인 (옵션)
        thumbnail = post.image.variant(:thumbnail).processed
        expect(thumbnail).to be_present

        # 실제 크기 테스트 (이미지 라이브러리에 따라 다름)
        if defined?(ImageProcessing::MiniMagick)
          dimensions = ImageProcessing::MiniMagick.new.metadata(thumbnail)
          expect(dimensions[:width]).to be <= 300
          expect(dimensions[:height]).to be <= 300
        end
      end
    end
  end
end
