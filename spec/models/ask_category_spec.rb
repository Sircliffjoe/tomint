# frozen_string_literal: true

require "rails_helper"

RSpec.describe AskCategory, type: :model do
  describe "validations and callbacks" do
    it "is valid with a name" do
      category = AskCategory.new(name: "Peer Pressure")
      expect(category).to be_valid
    end

    it "auto-generates slug from name" do
      category = AskCategory.create!(name: "School and Career")
      expect(category.slug).to eq("school-and-career")
    end

    it "orders by position" do
      cat2 = AskCategory.create!(name: "Second", position: 2)
      cat1 = AskCategory.create!(name: "First", position: 1)
      expect(AskCategory.ordered.first).to eq(cat1)
    end
  end
end
