require "rails_helper"

RSpec.describe "Internal messages", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:sender) do
    User.create!(
      first_name: "State",
      last_name: "Admin",
      email: "state-admin-message@example.com",
      password: "password",
      role: :public_user
    )
  end

  let(:recipient) do
    User.create!(
      first_name: "Director",
      last_name: "User",
      email: "director-message@example.com",
      password: "password",
      role: :public_user
    )
  end

  it "allows a non-super-admin user to send a message" do
    sign_in sender

    expect {
      post internal_messages_path, params: {
        internal_message: {
          recipient_id: recipient.id,
          subject: "Programme note",
          body: "Please review the plan."
        }
      }
    }.to change(InternalMessage, :count).by(1)

    expect(response).to redirect_to(internal_messages_path)
    expect(InternalMessage.last.recipient).to eq(recipient)
  end

  it "shows received messages and marks them read" do
    message = InternalMessage.create!(
      sender: sender,
      recipient: recipient,
      subject: "Programme note",
      body: "Please review the plan."
    )

    sign_in recipient
    get internal_message_path(message)

    expect(response).to have_http_status(:success)
    expect(message.reload).to be_read
  end

  it "shows the sender avatar on received messages when present" do
    sender.avatar.attach(
      io: Rails.root.join("spec/fixtures/files/avatar.png").open,
      filename: "avatar.png",
      content_type: "image/png"
    )
    InternalMessage.create!(
      sender: sender,
      recipient: recipient,
      subject: "Important Notice",
      body: "Please review this update."
    )

    sign_in recipient
    get internal_messages_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Important Notice")
    expect(response.body).to include("rails/active_storage")
    expect(response.body).to include(sender.full_name)
  end

  it "renders inside the authenticated dashboard layout" do
    state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
    state_user = User.create!(
      first_name: "State",
      last_name: "Coordinator",
      email: "state-coordinator-message@example.com",
      password: "password",
      role: :state_coordinator,
      state: state
    )

    sign_in state_user
    get internal_messages_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('id="sidebar"')
    expect(response.body).not_to include("tom-site-header")
    expect(response.body).to include(%(href="#{states_dashboard_path}"))
  end

  it "routes state coordinators to their state dashboard" do
    state = State.create!(name: "Lagos", code: "LAG", country: "Nigeria")
    state_user = User.create!(
      first_name: "Lagos",
      last_name: "Coordinator",
      email: "lagos-coordinator-message@example.com",
      password: "password",
      role: :state_coordinator,
      state: state
    )

    sign_in state_user
    get dashboard_path

    expect(response).to redirect_to(states_dashboard_path)
  end

  it "blocks super admin from internal messaging" do
    super_admin = User.create!(
      first_name: "Super",
      last_name: "Admin",
      email: "super-message@example.com",
      password: "password",
      role: :super_admin
    )

    sign_in super_admin
    get internal_messages_path

    expect(response).to redirect_to(dashboard_path)
  end
end
