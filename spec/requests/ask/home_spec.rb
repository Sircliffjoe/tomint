# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ask::HomeController", type: :request do
  let!(:category) { AskCategory.create!(name: "Faith & God", slug: "faith-god") }

  describe "GET /ask" do
    it "renders the landing page successfully" do
      get ask_root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("TOM ASK")
      expect(response.body).to include("You can ask. We will listen.")
    end
  end

  describe "POST /ask/submit" do
    it "creates a new anonymous question" do
      expect {
        post ask_submit_question_path, params: {
          ask_question: {
            body: "How do I know what career to choose?",
            ask_category_id: category.id,
            response_preference: "public_answer"
          }
        }
      }.to change(AskQuestion, :count).by(1)

      question = AskQuestion.last
      expect(response).to redirect_to(ask_confirmation_path(reference: question.public_reference))
      expect(question.anonymous_identifier).to be_present
      expect(question.public_reference).to be_present
    end

    it "creates a new anonymous question via turbo_stream format" do
      expect {
        post ask_submit_question_path, as: :turbo_stream, params: {
          ask_question: {
            body: "How do I know what career to choose?",
            ask_category_id: category.id,
            response_preference: "public_answer"
          }
        }
      }.to change(AskQuestion, :count).by(1)

      question = AskQuestion.last
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include(question.public_reference)
      expect(response.body).to include(ask_status_check_path(reference: question.public_reference))
    end

    it "blocks spam honeypot submissions" do
      expect {
        post ask_submit_question_path, params: {
          website_hp: "bot-url",
          ask_question: {
            body: "Spam link http://spam.com"
          }
        }
      }.not_to change(AskQuestion, :count)

      expect(response).to redirect_to(ask_root_path)
    end
  end

  describe "GET /ask/status" do
    let!(:question) { AskQuestion.create!(body: "Sample tracked question") }

    it "finds question by reference code" do
      get ask_status_check_path, params: { reference: question.public_reference }
      expect(response).to have_http_status(:success)
      expect(response.body).to include(question.public_reference)
    end
  end
end
