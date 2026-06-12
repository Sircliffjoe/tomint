require 'rails_helper'

RSpec.describe "Donations", type: :request do
  describe "GET /donations/new" do
    it "returns http success" do
      get new_donation_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("donation-giving-cause")
      expect(response.body).to include("data-copy-text")
    end
  end

  describe "POST /donations" do
    it "creates a donation" do
      expect {
        post donations_path, params: {
          donation: {
            amount: 5000,
            donor_email: "giver@example.com",
            purpose: "General Support"
          }
        }
      }.to change(Donation, :count).by(1)

      expect(response).to redirect_to(thank_you_donations_path(id: Donation.last.id))
      expect(Donation.last.display_currency).to eq("NGN")
    end
  end

  describe "GET /donations/thank_you" do
    it "returns http success" do
      donation = Donation.create!(
        amount: 5000,
        donor_email: "giver@example.com",
        purpose: "General Support",
        status: :successful
      )

      get thank_you_donations_path(id: donation.id)

      expect(response).to have_http_status(:success)
    end
  end
end
