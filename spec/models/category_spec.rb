require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "유효성 검증" do
    it "카테고리 이름이 없을 경우 유효성 검증 실패" do
      category = build(:category, name: nil)
      expect(category.valid?).to be(false)
      expect(category.errors[:name]).to include("카테고리 이름을 입력해주세요.")
    end

    it "카테고리 이름이 2글자 미만일 경우 유효성 검증 실패" do
      category = build(:category, :with_short_name)
      expect(category.valid?).to be(false)
      expect(category.errors[:name]).to include("카테고리 이름은 2~20글자의 한글 또는 영문만 사용 가능합니다.")
    end

    it "카테고리 이름이 20글자 초과일 경우 유효성 검증 실패" do
      category = build(:category, :with_long_name)
      expect(category.valid?).to be(false)
      expect(category.errors[:name]).to include("카테고리 이름은 2~20글자의 한글 또는 영문만 사용 가능합니다.")
    end

    it "카테고리 이름에 한글이나 영문이 아닌 문자가 포함될 경우 유효성 검증 실패" do
      category = build(:category, :with_invalid_chars)
      expect(category.valid?).to be(false)
      expect(category.errors[:name]).to include("카테고리 이름은 2~20글자의 한글 또는 영문만 사용 가능합니다.")
    end

    context "카테고리 이름이 유효한 형식일 경우 유효성 검증 성공" do
      it "한글만 포함된 경우" do
        category = build(:category, :with_korean_name)
        expect(category).to be_valid
      end

      it "영문만 포함된 경우" do
        category = build(:category, :with_english_name)
        expect(category).to be_valid
      end

      it "한글과 영문이 혼합된 경우" do
        category = build(:category, :with_mixed_name)
        expect(category).to be_valid
      end
    end
  end

  describe "관계 설정" do
    it "여러 즐겨찾기(favorites)를 가질 수 있다" do
      expect(Category.reflect_on_association(:favorites).macro).to eq(:has_many)
    end

    it "즐겨찾기를 통해 여러 사용자와 연결될 수 있다" do
      expect(Category.reflect_on_association(:favorite_users).macro).to eq(:has_many)
      expect(Category.reflect_on_association(:favorite_users).options[:through]).to eq(:favorites)
      expect(Category.reflect_on_association(:favorite_users).options[:source]).to eq(:user)
    end
  end
end
