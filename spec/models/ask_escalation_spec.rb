# frozen_string_literal: true

require "rails_helper"

RSpec.describe AskEscalation, type: :model do
  let(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_esc@tomint.org",
      password: "password123", role: :super_admin
    )
  end
  let(:question) { AskQuestion.create!(body: "Help me please, I am in danger.") }

  describe "creation" do
    it "creates an active escalation with valid attributes" do
      escalation = AskEscalation.create!(
        ask_question: question,
        created_by: admin,
        escalation_type: :urgent_crisis,
        severity: :critical,
        reason: "Imminent danger disclosure"
      )

      expect(escalation).to be_valid
      expect(escalation.critical?).to be true
      expect(escalation.open?).to be true
    end
  end
end
