require 'rails_helper'

RSpec.describe "Admin donations", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /admin/donations" do
    it "renders donations with missing legacy currency values" do
      admin = User.create!(
        first_name: "Super",
        last_name: "Admin",
        email: "admin-donations@example.com",
        password: "password",
        role: :super_admin
      )
      donation = Donation.create!(
        amount: 5000,
        donor_email: "giver@example.com",
        purpose: "General Support"
      )
      donation.update_columns(currency: nil, status: nil)

      sign_in admin
      get admin_donations_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("NGN")
      expect(response.body).to include("Pending")
    end
  end
end
