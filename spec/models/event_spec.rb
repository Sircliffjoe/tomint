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
end
