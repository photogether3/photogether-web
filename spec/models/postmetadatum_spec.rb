require 'rails_helper'

RSpec.describe PostMetadatum, type: :model do
  let(:post_item) { create(:post) }

  describe "관계 설정" do
    it "게시물(post)에 속한다" do
      expect(PostMetadatum.reflect_on_association(:post).macro).to eq(:belongs_to)
    end
  end

  describe "유효성 검증" do
    context "content(내용) 필드" do
      it "내용이 없을 경우 유효성 검증 실패" do
        metadata = build(:post_metadatum, post: post_item, content: nil)
        expect(metadata.valid?).to be(false)
        expect(metadata.errors[:content]).to include("can't be blank")
      end

      it "내용이 2글자 미만일 경우 유효성 검증 실패" do
        metadata = build(:post_metadatum, post: post_item, content: "A")
        expect(metadata.valid?).to be(false)
        expect(metadata.errors[:content]).to include("is too short (minimum is 2 characters)")
      end

      it "내용이 30글자 초과일 경우 유효성 검증 실패" do
        metadata = build(:post_metadatum, post: post_item, content: "A" * 31)
        expect(metadata.valid?).to be(false)
        expect(metadata.errors[:content]).to include("is too long (maximum is 30 characters)")
      end

      it "내용이 2~30글자일 경우 유효성 검증 성공" do
        metadata = build(:post_metadatum, post: post_item, content: "유효한 내용")
        expect(metadata).to be_valid
      end
    end

    context "is_public(공개 여부) 필드" do
      it "공개 여부가 nil일 경우 유효성 검증 실패" do
        metadata = build(:post_metadatum, post: post_item, is_public: nil)
        expect(metadata.valid?).to be(false)
        expect(metadata.errors[:is_public]).to include("is not included in the list")
      end

      it "공개 여부가 true일 경우 유효성 검증 성공" do
        metadata = build(:post_metadatum, post: post_item, is_public: true)
        expect(metadata).to be_valid
      end

      it "공개 여부가 false일 경우 유효성 검증 성공" do
        metadata = build(:post_metadatum, post: post_item, is_public: false)
        expect(metadata).to be_valid
      end
    end

    context "has_link(링크 포함 여부) 필드" do
      it "링크 포함 여부가 nil일 경우 유효성 검증 실패" do
        metadata = build(:post_metadatum, post: post_item, has_link: nil)
        expect(metadata.valid?).to be(false)
        expect(metadata.errors[:has_link]).to include("is not included in the list")
      end

      it "링크 포함 여부가 true일 경우 유효성 검증 성공" do
        metadata = build(:post_metadatum, post: post_item, has_link: true)
        expect(metadata).to be_valid
      end

      it "링크 포함 여부가 false일 경우 유효성 검증 성공" do
        metadata = build(:post_metadatum, post: post_item, has_link: false)
        expect(metadata).to be_valid
      end
    end
  end

  describe "생성 및 조회" do
    it "유효한 속성으로 메타데이터를 생성할 수 있다" do
      metadata = build(:post_metadatum, post: post_item)
      expect { metadata.save }.to change(PostMetadatum, :count).by(1)
    end

    it "링크가 있는 메타데이터를 생성할 수 있다" do
      metadata = build(:post_metadatum, :with_link, post: post_item)
      expect(metadata).to be_valid
      expect(metadata.has_link).to be(true)
    end

    it "비공개 메타데이터를 생성할 수 있다" do
      metadata = build(:post_metadatum, :private, post: post_item)
      expect(metadata).to be_valid
      expect(metadata.is_public).to be(false)
    end
  end

  describe "업데이트" do
    let!(:metadata) { create(:post_metadatum, post: post_item) }

    it "내용을 업데이트할 수 있다" do
      expect {
        metadata.update(content: "업데이트된 내용")
      }.to change { metadata.reload.content }.to("업데이트된 내용")
    end

    it "공개 여부를 업데이트할 수 있다" do
      expect {
        metadata.update(is_public: false)
      }.to change { metadata.reload.is_public }.from(true).to(false)
    end

    it "링크 포함 여부를 업데이트할 수 있다" do
      expect {
        metadata.update(has_link: true)
      }.to change { metadata.reload.has_link }.from(false).to(true)
    end
  end

  describe "삭제" do
    let!(:metadata) { create(:post_metadatum, post: post_item) }

    it "메타데이터를 삭제할 수 있다" do
      expect { metadata.destroy }.to change(PostMetadatum, :count).by(-1)
    end
  end

  describe "게시물과의 관계" do
    it "게시물이 삭제되면 해당 메타데이터도 삭제된다" do
      post_with_metadata = create(:post)
      metadata = create(:post_metadatum, post: post_with_metadata)

      expect { post_with_metadata.destroy }.to change(PostMetadatum, :count).by(-1)
    end
  end
end
