require "rails_helper"

RSpec.describe "Admin states", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Super",
      last_name: "Admin",
      email: "admin-states@example.com",
      password: "password",
      role: :super_admin
    )
  end

  before do
    sign_in admin
  end

  it "groups states and regions by country" do
    nigeria = Country.find_or_create_by!(name: "Nigeria", code: "NG")
    ghana = Country.create!(name: "Ghana", code: "GH")
    State.create!(name: "Edo", code: "EDO", country: nigeria)
    State.create!(name: "Greater Accra", code: "GAR", country: ghana)

    get admin_states_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Nigeria")
    expect(response.body).to include("Ghana")
    expect(response.body).to include("Edo")
    expect(response.body).to include("Greater Accra")
    expect(response.body).to include("1 state / region")
  end
end
