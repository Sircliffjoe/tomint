# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Ask::LiveSessionsController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_live_sess_test@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:live_session) do
    AskLiveSession.create!(
      title: "Conference Q&A 2026",
      created_by: admin,
      status: :active,
      voting_enabled: true,
      moderation_required: true
    )
  end
  let!(:live_question) do
    live_session.ask_questions.create!(
      body: "How do we handle school exam stress?",
      visibility: :pending_review,
      status: :new_intake
    )
  end

  before do
    sign_in admin
  end

  describe "GET /admin/ask/live" do
    it "renders the live sessions admin index" do
      get admin_ask_live_sessions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Conference Q&amp;A 2026")
    end
  end

  describe "GET /admin/ask/live/:id/moderation" do
    it "renders the live moderation console" do
      get moderation_admin_ask_live_session_path(live_session)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("LIVE MODERATION CONSOLE")
      expect(response.body).to include("How do we handle school exam stress?")
    end
  end

  describe "POST /admin/ask/live/:id/approve_question" do
    it "approves a pending question for the live feed" do
      post approve_question_admin_ask_live_session_path(live_session, question_id: live_question.id)

      expect(live_question.reload.approved_public?).to be true
    end
  end

  describe "GET /admin/ask/live/new" do
    it "renders the new session form" do
      get new_admin_ask_live_session_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Session Title")
    end
  end

  describe "GET /admin/ask/live/:id/edit" do
    it "renders the edit session form" do
      get edit_admin_ask_live_session_path(live_session)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Conference Q&amp;A 2026")
    end
  end

  describe "PATCH /admin/ask/live/:id" do
    it "updates session attributes" do
      patch admin_ask_live_session_path(live_session), params: {
        ask_live_session: { title: "Updated Conference Q&A" }
      }
      expect(response).to redirect_to(admin_ask_live_session_path(live_session))
      expect(live_session.reload.title).to eq("Updated Conference Q&A")
    end
  end
end
