# frozen_string_literal: true

require "rails_helper"

RSpec.describe AskResponse, type: :model do
  let(:user) do
    User.create!(
      first_name: "Responder", last_name: "Staff", email: "staff_resp@tomint.org",
      password: "password123", role: :ask_responder
    )
  end
  let(:question) { AskQuestion.create!(body: "How to overcome peer pressure?") }

  describe "publish!" do
    it "publishes response and updates question status and visibility" do
      response = question.ask_responses.create!(
        user: user,
        body: "Stand firm in your identity in Christ.",
        status: :draft,
        visibility: :internal_only
      )

      response.publish!
      expect(response.reload.published?).to be true
      expect(response.visibility).to eq("public_visible")
      expect(question.reload.answered?).to be true
      expect(question.approved_public?).to be true
    end
  end
end
