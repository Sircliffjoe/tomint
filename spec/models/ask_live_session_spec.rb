# frozen_string_literal: true

require "rails_helper"

RSpec.describe AskLiveSession, type: :model do
  let(:admin) do
    User.create!(
      first_name: "Admin", last_name: "User", email: "admin_live_test@tomint.org",
      password: "password123", role: :super_admin
    )
  end

  describe "generation of slug and access code" do
    it "auto generates slug and access code on create" do
      session = AskLiveSession.create!(
        title: "Youth Camp 2026",
        created_by: admin
      )
      expect(session.slug).to eq("youth-camp-2026")
      expect(session.access_code).to be_present
      expect(session.access_code.length).to eq(6)
    end
  end

  describe "QR code generation" do
    let(:session) do
      AskLiveSession.create!(
        title: "Live Q&A",
        created_by: admin
      )
    end

    it "generates SVG QR code string" do
      svg = session.qr_code_svg("http://example.com/ask/live/#{session.slug}")
      expect(svg).to include("<svg")
    end
  end
end
