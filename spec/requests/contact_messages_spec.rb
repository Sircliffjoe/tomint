require "rails_helper"

RSpec.describe "Contact messages", type: :request do
  before do
    Rails.cache.clear
  end

  describe "GET /contact" do
    it "renders the contact form" do
      get contact_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("contact_message[name]")
      expect(response.body).to include("form_started_at")
    end
  end

  describe "POST /contact" do
    it "creates a contact message" do
      expect {
        post contact_path, params: {
          form_started_at: 5.seconds.ago.to_i,
          contact_message: {
            name: "Jane Visitor",
            email: "jane@example.com",
            phone: "08000000000",
            subject: "General enquiry",
            message: "I would like to know more."
          }
        }
      }.to change(ContactMessage, :count).by(1)

      expect(response).to redirect_to(contact_path)
      expect(ContactMessage.last.email).to eq("jane@example.com")
    end

    it "does not create a contact message when the honeypot is filled" do
      expect {
        post contact_path, params: {
          form_started_at: 5.seconds.ago.to_i,
          website: "https://spam.example",
          contact_message: {
            name: "Spam Bot",
            email: "spam@example.com",
            subject: "General enquiry",
            message: "Spam"
          }
        }
      }.not_to change(ContactMessage, :count)

      expect(response).to redirect_to(contact_path)
    end
  end
end
