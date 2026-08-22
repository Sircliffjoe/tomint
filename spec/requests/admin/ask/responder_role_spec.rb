# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Responder Role Access Control", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:responder) do
    User.create!(
      first_name: "Tosin",
      last_name: "Responder",
      email: "responder_test@example.com",
      password: "password123",
      role: :responder
    )
  end

  before do
    sign_in responder
  end

  describe "Accessing all TOM ASK team operations" do
    it "allows access to the TOM ASK dashboard" do
      get admin_ask_dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "allows access to the TOM ASK questions queue" do
      get admin_ask_questions_path
      expect(response).to have_http_status(:success)
    end

    it "resolves dashboard_path to admin_ask_dashboard_path on login" do
      get dashboard_path
      expect(response).to redirect_to(admin_ask_dashboard_path)
    end

    it "allows access to Safeguarding Hub as a TOM ASK team member" do
      get admin_ask_safeguarding_index_path
      expect(response).to have_http_status(:success)
    end

    it "allows access to Ask Categories" do
      get admin_ask_categories_path
      expect(response).to have_http_status(:success)
    end

    it "allows access to Live Sessions" do
      get admin_ask_live_sessions_path
      expect(response).to have_http_status(:success)
    end

    it "allows access to ASK Analytics" do
      get admin_ask_analytics_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "Strictly restricted from non-ASK sections" do
    it "blocks access to standard admin dashboard" do
      get admin_dashboard_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks access to reports" do
      get reports_path
      expect(response).to redirect_to(admin_ask_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to access reports.")
    end

    it "blocks access to internal messages" do
      get internal_messages_path
      expect(response).to redirect_to(admin_ask_dashboard_path)
      expect(flash[:alert]).to eq("You are not authorized to access internal messages.")
    end

    it "blocks access to user management" do
      get admin_users_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks access to directorates dashboard" do
      get directorates_dashboard_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks access to states dashboard" do
      get states_dashboard_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks access to events management" do
      get admin_events_path
      expect(response).to redirect_to(root_path)
    end

    it "blocks access to trainings management" do
      get admin_trainings_path
      expect(response).to redirect_to(root_path)
    end
  end
end
