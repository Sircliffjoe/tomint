require "rails_helper"

RSpec.describe "Passwords", type: :request do
  describe "GET /users/password/new" do
    it "renders the branded internal reset form" do
      get new_user_password_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Choose a new password")
      expect(response.body).to include("No reset email will be sent")
    end
  end

  describe "POST /users/password" do
    it "changes a user's password without sending email" do
      user = User.create!(
        first_name: "Reset",
        last_name: "User",
        email: "reset-user@example.com",
        password: "old-password",
        must_change_password: true
      )

      post user_password_path, params: {
        user: {
          email: user.email,
          password: "new-password",
          password_confirmation: "new-password"
        }
      }

      expect(response).to redirect_to(new_user_session_path)
      expect(user.reload).not_to be_must_change_password
      expect(user.valid_password?("new-password")).to be(true)
    end

    it "does not change a password when confirmation is wrong" do
      user = User.create!(
        first_name: "Reset",
        last_name: "User",
        email: "failed-reset@example.com",
        password: "old-password"
      )

      post user_password_path, params: {
        user: {
          email: user.email,
          password: "new-password",
          password_confirmation: "different-password"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(user.reload.valid_password?("old-password")).to be(true)
    end
  end
end
