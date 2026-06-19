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
    before do
      Rails.cache.clear
    end

    it "creates a donation" do
      expect {
        post donations_path, params: {
          form_started_at: 5.seconds.ago.to_i,
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

    it "does not create a donation when the honeypot is filled" do
      expect {
        post donations_path, params: {
          form_started_at: 5.seconds.ago.to_i,
          website: "https://spam.example",
          donation: {
            amount: 5000,
            donor_email: "bot@example.com",
            purpose: "General Support"
          }
        }
      }.not_to change(Donation, :count)

      expect(response).to redirect_to(thank_you_donations_path)
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
