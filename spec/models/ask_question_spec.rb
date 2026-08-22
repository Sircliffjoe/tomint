# frozen_string_literal: true

require "rails_helper"

RSpec.describe AskQuestion, type: :model do
  let(:category) { AskCategory.create!(name: "Faith & Doubts", slug: "faith-doubts") }

  describe "validations" do
    it "is valid with valid attributes" do
      question = AskQuestion.new(
        body: "How do I know God's plan for my life?",
        ask_category: category
      )
      expect(question).to be_valid
    end

    it "requires body" do
      question = AskQuestion.new(body: nil)
      expect(question).not_to be_valid
    end

    it "generates a public reference automatically" do
      question = AskQuestion.create!(
        body: "What should I do when I feel lonely at school?"
      )
      expect(question.public_reference).to be_present
      expect(question.public_reference).to start_with("ASK-")
    end
  end

  describe "enums & defaults" do
    let(:question) { AskQuestion.create!(body: "Sample question?") }

    it "defaults to new_intake status and pending_review visibility" do
      expect(question.new_intake?).to be true
      expect(question.pending_review?).to be true
    end

    it "defaults to normal priority" do
      expect(question.priority_normal?).to be true
    end
  end

  describe "upvoting" do
    let(:question) { AskQuestion.create!(body: "Will this question get upvotes?") }

    it "increments upvote count with a unique voter token" do
      expect {
        result = question.upvote_by!("token-user-1")
        expect(result).to be true
      }.to change { question.reload.upvotes_count }.by(1)
    end

    it "prevents duplicate upvotes by the same voter token" do
      question.upvote_by!("token-user-1")
      expect {
        result = question.upvote_by!("token-user-1")
        expect(result).to be false
      }.not_to change { question.reload.upvotes_count }
    end
  end

  describe "assignments" do
    let(:admin) do
      User.create!(
        first_name: "Admin", last_name: "User", email: "admin_test@tomint.org",
        password: "password123", role: :super_admin
      )
    end
    let(:responder) do
      User.create!(
        first_name: "Responder", last_name: "User", email: "responder_test@tomint.org",
        password: "password123", role: :responder
      )
    end
    let(:question) { AskQuestion.create!(body: "Can someone help me understand baptism?") }

    it "assigns responder and logs audit action" do
      question.assign_to!(responder, admin, "Please handle this baptism question")
      expect(question.reload.current_assignee).to eq(responder)
      expect(question.awaiting_response?).to be true
      expect(question.ask_moderation_actions.count).to eq(1)
    end
  end
end
