require "rails_helper"

RSpec.describe "Profiles", type: :request do
  include Devise::Test::IntegrationHelpers

  it "forces users with temporary passwords to change them" do
    user = User.create!(
      first_name: "Temp",
      last_name: "User",
      email: "temp-user@example.com",
      password: "temp-password",
      must_change_password: true
    )

    sign_in user
    get reports_path

    expect(response).to redirect_to(edit_profile_path)
    expect(flash[:alert]).to eq("Please change your temporary password before continuing.")
  end

  it "allows a user to change password in the profile" do
    user = User.create!(
      first_name: "Temp",
      last_name: "User",
      email: "profile-password@example.com",
      password: "temp-password",
      must_change_password: true
    )

    sign_in user
    patch profile_path, params: {
      user: {
        current_password: "temp-password",
        password: "new-secure-password",
        password_confirmation: "new-secure-password"
      }
    }

    expect(response).to redirect_to(profile_path)
    expect(user.reload).not_to be_must_change_password
    expect(user.password_changed_at).to be_present
    expect(user.valid_password?("new-secure-password")).to be(true)
  end
end
