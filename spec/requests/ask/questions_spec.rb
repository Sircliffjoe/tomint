# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ask::QuestionsController", type: :request do
  let!(:category) { AskCategory.create!(name: "Friendship", slug: "friendship") }
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "qa_admin@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:question) do
    q = AskQuestion.create!(
      body: "How do I make godly friends at my new school?",
      ask_category: category,
      visibility: :approved_public,
      status: :answered,
      answered_at: Time.current
    )
    q.ask_responses.create!(
      user: admin,
      body: "Pray for discernment and be friendly first (Proverbs 18:24).",
      status: :published,
      visibility: :public_visible,
      published_at: Time.current
    )
    q
  end

  describe "GET /ask/questions" do
    it "renders the public library of answered questions" do
      get ask_questions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("How do I make godly friends")
    end

    it "filters by category" do
      get ask_questions_path, params: { category: "friendship" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("How do I make godly friends")
    end
  end

  describe "GET /ask/questions/:id" do
    it "renders the question detail page and increments view count" do
      expect {
        get ask_question_path(question)
      }.to change { question.reload.views_count }.by(1)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Pray for discernment and be friendly first")
    end
  end
end
