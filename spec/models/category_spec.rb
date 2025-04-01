require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "유효성 검증" do
    it "카테고리 이름이 없을 경우 유효성 검증 실패" do
      category = Category.new(name: nil)
      expect(category.valid?).to be(false)
    end

    it "카테고리 이름이 2글자 미만일 경우 유효성 검증 실패" do
      category = Category.new(name: "A")
      expect(category.valid?).to be(false)
    end

    it "카테고리 이름이 20글자 초과일 경우 유효성 검증 실패" do
      category = Category.new(name: "A" * 21)
      expect(category.valid?).to be(false)
    end

    it "카테고리 이름에 한글이나 영문이 아닌 문자가 포함될 경우 유효성 검증 실패" do
      category = Category.new(name: "Test123")
      expect(category.valid?).to be(false)
    end

    it "카테고리 이름이 유효한 형식일 경우 유효성 검증 성공" do
      # 한글만 포함된 경우
      category1 = Category.new(name: "테스트")
      expect(category1.valid?).to be(true)

      # 영문만 포함된 경우
      category2 = Category.new(name: "Test")
      expect(category2.valid?).to be(true)

      # 한글과 영문이 혼합된 경우
      category3 = Category.new(name: "테스트Test")
      expect(category3.valid?).to be(true)
    end
  end
end
