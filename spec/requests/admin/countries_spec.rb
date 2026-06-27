require "rails_helper"

RSpec.describe "Admin countries", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin-countries@example.com",
      password: "password",
      role: :super_admin
    )
  end

  before do
    sign_in admin
  end

  it "creates a country" do
    post admin_countries_path, params: {
      country: {
        name: "Ghana",
        code: "GH",
        phone: "+233 123 456",
        email: "ghana@example.org",
        status: "active"
      }
    }

    country = Country.find_by!(code: "GH")

    expect(response).to redirect_to(admin_countries_path)
    expect(country.name).to eq("Ghana")
    expect(country.phone).to eq("+233 123 456")
  end

  it "lists countries" do
    Country.create!(name: "United Kingdom", code: "UK")

    get admin_countries_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("United Kingdom")
    expect(response.body).to include("States / Regions")
  end
end
