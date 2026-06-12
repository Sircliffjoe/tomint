require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "POST /events/:event_id/registrations" do
    it "allows guest registration for upcoming events" do
      event = Event.create!(
        title: "Guest Camp",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :free
      )

      expect {
        post event_registrations_path(event), params: {
          registration: {
            guest_name: "Guest Visitor",
            guest_email: "guest@example.com",
            guest_phone: "08000000000"
          }
        }
      }.to change(Registration, :count).by(1)

      expect(response).to redirect_to(event_path(event))
      expect(Registration.last.user).to be_nil
      expect(Registration.last.guest_email).to eq("guest@example.com")
    end

    it "allows registration for upcoming events" do
      user = User.create!(
        first_name: "Event",
        last_name: "Guest",
        email: "upcoming-registration@example.com",
        password: "password"
      )
      event = Event.create!(
        title: "Upcoming Camp",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :free
      )

      sign_in user

      expect {
        post event_registrations_path(event)
      }.to change(Registration, :count).by(1)

      expect(response).to redirect_to(event_registration_path(event, Registration.last))
    end

    it "rejects registration for past events" do
      user = User.create!(
        first_name: "Event",
        last_name: "Guest",
        email: "past-registration@example.com",
        password: "password"
      )
      event = Event.create!(
        title: "Past Camp",
        start_time: 1.week.ago,
        end_time: 1.week.ago + 2.hours,
        event_type: :free,
        registration_open: true
      )

      sign_in user

      expect {
        post event_registrations_path(event)
      }.not_to change(Registration, :count)

      expect(response).to redirect_to(event_path(event))
      expect(flash[:alert]).to eq("Registration is closed for this event.")
    end
  end
end
