# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Ask::QuestionsController", type: :request do
  let!(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_q_test@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let!(:responder) do
    User.create!(
      first_name: "Responder", last_name: "User", email: "responder_q_test@tomint.org",
      password: "password123", role: :ask_responder
    )
  end
  let!(:category) { AskCategory.create!(name: "General Topic", slug: "general-topic") }
  let!(:question) { AskQuestion.create!(body: "My raw question with a person's name John Doe from St. Paul School") }

  before do
    sign_in admin
  end

  describe "GET /admin/ask/questions" do
    it "renders the questions queue" do
      get admin_ask_questions_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Questions Queue")
      expect(response.body).to include(question.public_reference)
    end
  end

  describe "GET /admin/ask/questions/:id" do
    it "renders the question workbench" do
      get admin_ask_question_path(question)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(question.public_reference)
      expect(response.body).to include("Anonymize &amp; Classify Question")
    end
  end

  describe "PATCH /admin/ask/questions/:id/moderate" do
    it "updates question anonymized body and category" do
      patch moderate_admin_ask_question_path(question), params: {
        ask_question: {
          anonymized_body: "How do I handle peer conflict at school?",
          ask_category_id: category.id,
          priority: "high"
        }
      }

      expect(response).to redirect_to(admin_ask_question_path(question))
      expect(question.reload.anonymized_body).to eq("How do I handle peer conflict at school?")
      expect(question.ask_category).to eq(category)
      expect(question.priority_high?).to be true
    end
  end

  describe "POST /admin/ask/questions/:id/assign" do
    it "assigns the question to a responder" do
      post assign_admin_ask_question_path(question), params: {
        assignee_id: responder.id,
        notes: "Please write a response"
      }

      expect(response).to redirect_to(admin_ask_question_path(question))
      expect(question.reload.current_assignee).to eq(responder)
    end
  end
end
