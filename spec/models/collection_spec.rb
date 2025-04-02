require 'rails_helper'

RSpec.describe Collection, type: :model do
  # 팩토리 사용
  let(:user) { create(:user) }
  let(:category) { create(:category) }

  describe "유효성 검증" do
    context "제목 유효성 검증" do
      it "제목이 없을 경우 유효성 검증 실패" do
        collection = build(:collection, title: nil)
        expect(collection.valid?).to be(false)
        expect(collection.errors[:title]).to include("can't be blank")
      end

      it "제목이 2글자 미만일 경우 유효성 검증 실패" do
        collection = build(:collection, :with_short_title)
        expect(collection.valid?).to be(false)
        expect(collection.errors[:title]).to include("제목은 2~20글자 사이여야 합니다.")
      end

      it "제목이 20글자 초과일 경우 유효성 검증 실패" do
        collection = build(:collection, title: "A" * 21)
        expect(collection.valid?).to be(false)
        expect(collection.errors[:title]).to include("제목은 2~20글자 사이여야 합니다.")
      end

      it "제목이 2~20글자일 경우 유효성 검증 성공" do
        collection = build(:collection)
        expect(collection).to be_valid
      end
    end

    context "타입 유효성 검증" do
      it "타입이 정의된 값이 아닐 경우 유효성 검증 실패" do
        collection = build(:collection, type: "INVALID_TYPE")
        expect(collection.valid?).to be(false)
        expect(collection.errors[:type]).to include("타입은 DEFAULT, UNCATEGORIZED, TRASH 중 하나여야 합니다.")
      end

      it "타입이 DEFAULT일 경우 유효성 검증 성공" do
        collection = build(:collection, type: "DEFAULT")
        expect(collection).to be_valid
      end

      it "타입이 UNCATEGORIZED일 경우 유효성 검증 성공" do
        collection = build(:collection, :uncategorized)
        expect(collection).to be_valid
      end

      it "타입이 TRASH일 경우 유효성 검증 성공" do
        collection = build(:collection, type: "TRASH")
        expect(collection).to be_valid
      end
    end
  end

  describe "관계 설정" do
    it "사용자(user)에 속한다" do
      expect(Collection.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it "카테고리(category)에 속할 수 있다(optional)" do
      association = Collection.reflect_on_association(:category)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:optional]).to eq(true)
    end

    it "여러 게시물(posts)을 가질 수 있다" do
      expect(Collection.reflect_on_association(:posts).macro).to eq(:has_many)
    end
  end
end
