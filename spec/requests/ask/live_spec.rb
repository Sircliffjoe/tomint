# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ask::LiveController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "live_req_admin@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:live_session) do
    AskLiveSession.create!(
      title: "Camp Fire Ask Anything",
      created_by: admin,
      status: :active,
      voting_enabled: true,
      moderation_required: true
    )
  end
  let!(:live_question) do
    live_session.ask_questions.create!(
      body: "What is your advice on career choices?",
      visibility: :approved_public,
      status: :new_intake
    )
  end

  describe "GET /ask/live" do
    it "renders the live sessions index" do
      get ask_live_index_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Camp Fire Ask Anything")
    end

    it "redirects by access code when entered" do
      get ask_live_index_path, params: { code: live_session.access_code }
      expect(response).to redirect_to(ask_live_session_path(live_session))
    end
  end

  describe "GET /ask/live/:slug" do
    it "renders the participant view" do
      get ask_live_session_path(live_session)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Camp Fire Ask Anything")
      expect(response.body).to include("What is your advice on career choices?")
    end
  end

  describe "POST /ask/live/:slug/questions" do
    it "submits a live question into moderation" do
      expect {
        post ask_live_create_question_path(live_session), params: {
          ask_question: {
            body: "How do we handle fear of the future?"
          }
        }
      }.to change(live_session.ask_questions, :count).by(1)

      expect(response).to redirect_to(ask_live_session_path(live_session))
    end

    it "submits a live question into moderation via turbo_stream" do
      expect {
        post ask_live_create_question_path(live_session), as: :turbo_stream, params: {
          ask_question: {
            body: "How do we handle fear of the future?"
          }
        }
      }.to change(live_session.ask_questions, :count).by(1)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end

  describe "POST /ask/live/:slug/questions/:id/vote" do
    it "upvotes the question" do
      expect {
        post ask_live_vote_question_path(live_session, live_question)
      }.to change { live_question.reload.upvotes_count }.by(1)
    end

    it "upvotes the question via turbo_stream" do
      expect {
        post ask_live_vote_question_path(live_session, live_question), as: :turbo_stream
      }.to change { live_question.reload.upvotes_count }.by(1)

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end
  end

  describe "GET /ask/live/:slug/display" do
    it "renders the projector display screen" do
      get ask_live_display_path(live_session)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("PRESENTATION")
    end
  end
end
