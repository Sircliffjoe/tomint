# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ask::SafeguardingDetector do
  describe ".analyze" do
    it "detects critical self-harm keywords and returns severe result" do
      result = described_class.analyze("I feel like I want to commit suicide and end my life")
      expect(result[:flagged]).to be true
      expect(result[:urgent]).to be true
      expect(result[:severity]).to eq(:critical)
      expect(result[:reasons].to_s).to include("Detected critical term: 'suicide'")
    end

    it "detects abuse keywords and returns high severity result" do
      result = described_class.analyze("My uncle is molesting me at home")
      expect(result[:flagged]).to be true
      expect(result[:urgent]).to be true
      expect(result[:severity]).to eq(:critical)
    end

    it "detects sensitive keywords with high severity" do
      result = described_class.analyze("I am struggling because someone is harming me at home")
      expect(result[:flagged]).to be true
      expect(result[:severity]).to eq(:high)
    end

    it "returns unflagged for general faith/life questions" do
      result = described_class.analyze("What is the meaning of John 3:16 and how do I share it with friends?")
      expect(result[:flagged]).to be false
      expect(result[:urgent]).to be false
      expect(result[:severity]).to eq(:low)
    end
  end

  describe ".apply_to_question!" do
    let(:question) { AskQuestion.create!(body: "I am in danger and someone is hurting me") }

    it "flags question, marks status as urgent, and sets visibility to safeguarding_restricted" do
      described_class.apply_to_question!(question)
      expect(question.safeguarding_flag?).to be true
      expect(question.urgent_flag?).to be true
      expect(question.urgent?).to be true
      expect(question.safeguarding_restricted?).to be true
      expect(question.priority_urgent?).to be true
    end
  end
end
