require 'rails_helper'

RSpec.describe State, type: :model do
  it "allows the same state name in different countries" do
    nigeria = Country.create!(name: "Nigeria", code: "NG")
    usa = Country.create!(name: "United States", code: "US")

    State.create!(name: "Delta", code: "DEL", country: nigeria)
    state = State.new(name: "Delta", code: "DLT", country: usa)

    expect(state).to be_valid
  end

  it "does not allow duplicate state codes within the same country" do
    nigeria = Country.create!(name: "Nigeria", code: "NG")

    State.create!(name: "Delta", code: "DEL", country: nigeria)
    state = State.new(name: "Different Delta", code: "DEL", country: nigeria)

    expect(state).not_to be_valid
    expect(state.errors[:code]).to be_present
  end

  it "keeps legacy country string assignment working" do
    state = State.create!(name: "Lagos", code: "LAG", country: "Nigeria")

    expect(state.country.name).to eq("Nigeria")
    expect(state[:country]).to eq("Nigeria")
  end
end
