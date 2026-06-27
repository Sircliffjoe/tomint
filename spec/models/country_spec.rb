require "rails_helper"

RSpec.describe Country, type: :model do
  it "normalizes country codes and creates a slug" do
    country = Country.create!(name: "Ghana", code: "gh")

    expect(country.code).to eq("GH")
    expect(country.slug).to eq("ghana")
  end
end
