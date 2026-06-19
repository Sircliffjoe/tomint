require "rails_helper"

RSpec.describe "State profile", type: :request do
  include Devise::Test::IntegrationHelpers

  it "shows the assigned state dashboard with map placeholder" do
    state = State.create!(
      name: "Delta",
      code: "DEL",
      country: "Nigeria",
      year_created: 1993,
      description: "TOM Delta State chapter."
    )
    user = User.create!(
      first_name: "State",
      last_name: "Coordinator",
      email: "state-profile@example.com",
      password: "password",
      role: :state_coordinator,
      state: state
    )

    sign_in user
    get states_state_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("My State - Delta")
    expect(response.body).to include("Delta Map")
    expect(response.body).to include("No map image uploaded")
    expect(response.body).to include("Operational Areas")
  end
end
