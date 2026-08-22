# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Ask::SafeguardingController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_safe_test@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:responder) do
    User.create!(
      first_name: "Responder", last_name: "User", email: "resp_safe_test@tomint.org",
      password: "password123", role: :responder
    )
  end
  let!(:regular_user) do
    User.create!(
      first_name: "Regular", last_name: "User", email: "reg_safe_test@tomint.org",
      password: "password123", role: :public_user
    )
  end
  let!(:safeguarding_question) do
    AskQuestion.create!(
      body: "I am feeling depressed and having thoughts of ending my life",
      safeguarding_flag: true,
      urgent_flag: true,
      status: :urgent,
      visibility: :safeguarding_restricted
    )
  end

  describe "authorization" do
    it "denies access to non-safeguarding users" do
      sign_in regular_user
      get admin_ask_safeguarding_index_path
      expect(response).to redirect_to(admin_ask_dashboard_path)
    end

    it "grants access to responder" do
      sign_in responder
      get admin_ask_safeguarding_index_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Safeguarding &amp; Crisis Hub")
      expect(response.body).to include(safeguarding_question.public_reference)
    end
  end

  describe "POST /admin/ask/safeguarding/:id/escalate" do
    before { sign_in responder }

    it "creates a formal escalation case" do
      expect {
        post escalate_admin_ask_safeguarding_path(safeguarding_question), params: {
          ask_escalation: {
            escalation_type: "urgent_crisis",
            severity: "critical",
            reason: "Suicidal ideation reported by teenager",
            assigned_safeguarding_lead_id: responder.id
          }
        }
      }.to change(safeguarding_question.ask_escalations, :count).by(1)

      expect(response).to redirect_to(admin_ask_safeguarding_path(safeguarding_question))
      expect(safeguarding_question.reload.safeguarding_escalated?).to be true
    end
  end
end
