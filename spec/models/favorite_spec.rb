require 'rails_helper'

RSpec.describe Favorite, type: :model do
  # 테스트에 필요한 사용자와 카테고리 미리 생성
  let(:user) { create(:user) }
  let(:category) { create(:category) }

  describe "관계 설정" do
    it "사용자(user)에 속한다" do
      expect(Favorite.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it "카테고리(category)에 속한다" do
      expect(Favorite.reflect_on_association(:category).macro).to eq(:belongs_to)
    end
  end

  describe "유효성 검증" do
    context "필수 필드 검증" do
      it "사용자 ID가 없을 경우 유효성 검증 실패" do
        favorite = build(:favorite, user: nil)
        expect(favorite.valid?).to be(false)
        expect(favorite.errors[:user_id]).to include("사용자 ID는 필수입니다.")
      end

      it "카테고리 ID가 없을 경우 유효성 검증 실패" do
        favorite = build(:favorite, category: nil)
        expect(favorite.valid?).to be(false)
        expect(favorite.errors[:category_id]).to include("카테고리 ID는 필수입니다.")
      end

      it "사용자와 카테고리가 모두 있을 경우 유효성 검증 성공" do
        favorite = build(:favorite, user: user, category: category)
        expect(favorite).to be_valid
      end
    end

    context "중복 검증" do
      let!(:existing_favorite) { create(:favorite, user: user, category: category) }

      it "동일한 사용자-카테고리 조합이 이미 존재할 경우 유효성 검증 실패" do
        duplicate_favorite = build(:favorite, user: user, category: category)

        expect(duplicate_favorite.valid?).to be(false)
        expect(duplicate_favorite.errors[:user_id]).to include("이미 즐겨찾기에 추가된 카테고리입니다.")
      end

      it "다른 사용자가 같은 카테고리를 즐겨찾기할 수 있다" do
        different_user = create(:user)
        different_user_favorite = build(:favorite, user: different_user, category: category)

        expect(different_user_favorite).to be_valid
      end

      it "같은 사용자가 다른 카테고리를 즐겨찾기할 수 있다" do
        different_category = create(:category)
        different_category_favorite = build(:favorite, user: user, category: different_category)

        expect(different_category_favorite).to be_valid
      end
    end
  end

  describe "생성 및 삭제" do
    it "유효한 속성으로 즐겨찾기를 생성할 수 있다" do
      favorite = build(:favorite, user: user, category: category)
      expect { favorite.save }.to change(Favorite, :count).by(1)
    end

    it "즐겨찾기를 삭제할 수 있다" do
      favorite = create(:favorite, user: user, category: category)
      expect { favorite.destroy }.to change(Favorite, :count).by(-1)
    end
  end
end
