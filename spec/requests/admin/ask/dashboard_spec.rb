# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Ask::DashboardController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_dash@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:moderator) do
    User.create!(
      first_name: "Mod", last_name: "User", email: "mod_dash@tomint.org",
      password: "password123", role: :ask_moderator
    )
  end

  before do
    sign_in admin
  end

  describe "GET /admin/ask" do
    it "renders the admin dashboard successfully" do
      get admin_ask_dashboard_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("TOM ASK Dashboard")
    end
  end
end
