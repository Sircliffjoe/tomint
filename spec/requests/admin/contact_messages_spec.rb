require "rails_helper"

RSpec.describe "Admin contact messages", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Super",
      last_name: "Admin",
      email: "admin-contact@example.com",
      password: "password",
      role: :super_admin
    )
  end

  before do
    sign_in admin
  end

  it "lists contact messages" do
    ContactMessage.create!(
      name: "Jane Visitor",
      email: "jane@example.com",
      subject: "General enquiry",
      message: "Please contact me."
    )

    get admin_contact_messages_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Jane Visitor")
    expect(response.body).to include("1 unread message")
  end

  it "marks a message read when viewed" do
    message = ContactMessage.create!(
      name: "Jane Visitor",
      email: "jane@example.com",
      subject: "Training",
      message: "Please contact me."
    )

    get admin_contact_message_path(message)

    expect(response).to have_http_status(:success)
    expect(message.reload).to be_read
  end
end
