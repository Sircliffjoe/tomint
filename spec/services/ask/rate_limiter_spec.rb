# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ask::RateLimiter do
  let(:request) { ActionDispatch::TestRequest.create }
  let(:session_token) { "test-anon-token-123" }

  describe ".check_submission" do
    it "blocks bot if honeypot parameter is present" do
      params = { website_hp: "bot-payload", ask_question: { body: "Real question" } }
      result = described_class.check_submission(request, params, session_token)
      expect(result[:allowed]).to be false
      expect(result[:reason]).to eq("Spam detected.")
    end

    it "allows submission when params are clean" do
      params = { website_hp: "", ask_question: { body: "Valid question here" } }
      result = described_class.check_submission(request, params, session_token)
      expect(result[:allowed]).to be true
      expect(result[:ip_hash]).to be_present
    end

    it "blocks duplicate submission of exact same body from same token" do
      params = { website_hp: "", ask_question: { body: "Identical body submission" } }
      # Create first submission
      AskQuestion.create!(body: "Identical body submission", anonymous_identifier: session_token)

      result = described_class.check_submission(request, params, session_token)
      expect(result[:allowed]).to be false
      expect(result[:reason]).to include("already recently submitted")
    end
  end

  describe ".check_vote" do
    let(:question) { AskQuestion.create!(body: "Question to vote on") }

    it "allows first vote" do
      result = described_class.check_vote(request, question.id, "voter-token-1")
      expect(result[:allowed]).to be true
    end

    it "blocks duplicate vote by same token" do
      AskVote.create!(ask_question: question, voter_token: "voter-token-1")
      result = described_class.check_vote(request, question.id, "voter-token-1")
      expect(result[:allowed]).to be false
      expect(result[:reason]).to include("already voted")
    end
  end
end
