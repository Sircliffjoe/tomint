require "rails_helper"

RSpec.describe "Contact page", type: :request do
  it "renders countries and their states as contact locations" do
    ghana = Country.create!(
      name: "Ghana",
      code: "GH",
      phone: "+233 123 456",
      email: "ghana@example.org"
    )
    state = State.create!(
      name: "Greater Accra",
      code: "GA",
      country: ghana,
      contact_info: "Coordinator: TOM Ghana"
    )
    Area.create!(name: "Adenta", state: state)

    get contact_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Choose Your Location")
    expect(response.body).to include("Ghana")
    expect(response.body).to include("Greater Accra")
    expect(response.body).to include("Coordinator: TOM Ghana")
    expect(response.body).to include("Adenta")
    expect(response.body).to include("data-location-title-suffix=\"\"")
  end

  it "renders a country contact card when a country has no states yet" do
    Country.create!(
      name: "United Kingdom",
      code: "UK",
      phone: "+44 123 456",
      email: "uk@example.org"
    )

    get contact_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("United Kingdom")
    expect(response.body).to include("+44 123 456")
    expect(response.body).to include("uk@example.org")
  end
end
