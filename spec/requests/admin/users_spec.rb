require "rails_helper"

RSpec.describe "Admin users", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Super",
      last_name: "Admin",
      email: "super-users@example.com",
      password: "password",
      role: :super_admin
    )
  end

  before do
    sign_in admin
  end

  it "creates users with a unique temporary password" do
    post admin_users_path, params: {
      user: {
        first_name: "State",
        last_name: "Worker",
        email: "state-worker@example.com",
        role: "public_user"
      }
    }

    follow_redirect!
    user = User.find_by!(email: "state-worker@example.com")
    generated_password = response.body.match(/data-temporary-password="([^"]+)"/)[1]

    expect(response.body).to include("Temporary Login Password")
    expect(user).to be_must_change_password
    expect(user.valid_password?(generated_password)).to be(true)
    expect(user.valid_password?("password123")).to be(false)
  end

  it "regenerates a temporary password for a user" do
    user = User.create!(
      first_name: "State",
      last_name: "Worker",
      email: "reset-worker@example.com",
      password: "old-password",
      role: :public_user
    )

    patch reset_password_admin_user_path(user)

    follow_redirect!
    generated_password = response.body.match(/data-temporary-password="([^"]+)"/)[1]

    expect(user.reload).to be_must_change_password
    expect(user.valid_password?(generated_password)).to be(true)
    expect(user.valid_password?("old-password")).to be(false)
  end
end
