require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "#registration_open?" do
    it "is true for upcoming events regardless of the stored flag" do
      event = described_class.new(
        title: "Upcoming Camp",
        start_time: 1.day.from_now,
        end_time: 1.day.from_now + 2.hours,
        registration_open: false
      )

      expect(event.registration_open?).to be(true)
    end

    it "is false for past events regardless of the stored flag" do
      event = described_class.new(
        title: "Past Camp",
        start_time: 1.day.ago,
        end_time: 1.day.ago + 2.hours,
        registration_open: true
      )

      expect(event.registration_open?).to be(false)
    end
  end

  describe "#camp_information_event?" do
    it "is true for information events with camp in the title" do
      event = described_class.new(title: "TOM Camp 2026", event_type: :information)

      expect(event.camp_information_event?).to be(true)
    end

    it "is false for non-camp information events" do
      event = described_class.new(title: "Workers Retreat", event_type: :information)

      expect(event.camp_information_event?).to be(false)
    end

    it "is false for camp events that accept registration" do
      event = described_class.new(title: "TOM Camp 2026", event_type: :free)

      expect(event.camp_information_event?).to be(false)
    end
  end

  describe "camp details persistence" do
    it "does not create empty placeholder camp details automatically" do
      event = described_class.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      expect(event.camp_details).to be_empty
    end
  end

  describe "optional event details" do
    it "allows schedule, location, state, price, and currency to be blank" do
      event = described_class.new(title: "Umbrella Camp", event_type: :paid)

      expect(event).to be_valid
      expect(event.date_label).to eq("Date TBA")
      expect(event.time_label).to eq("Time TBA")
      expect(event.location_label).to eq("Location TBA")
      expect(event.display_price).to eq("Price TBA")
    end
  end
end
