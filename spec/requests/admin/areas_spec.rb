require 'rails_helper'

RSpec.describe "Admin areas", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin-areas@example.com",
      password: "password",
      role: :super_admin
    )
  end

  let(:state) { State.create!(name: "Delta", code: "DEL", country: "Nigeria") }

  before do
    sign_in admin
  end

  it "creates an area under a state" do
    post admin_state_areas_path(state), params: {
      area: {
        name: "Asaba Central",
        description: "Central Area"
      }
    }

    expect(response).to redirect_to(admin_state_areas_path(state))
    expect(state.areas.find_by(name: "Asaba Central")).to be_present
  end

  it "renders the new area form" do
    get new_admin_state_area_path(state)

    expect(response).to have_http_status(:success)
    expect(response.body).to include("New Area")
    expect(response.body).to include("Asaba Central")
  end
end
