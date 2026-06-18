require 'rails_helper'

RSpec.describe "Events", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /events" do
    it "returns http success" do
      get events_path

      expect(response).to have_http_status(:success)
    end

    it "uses the public layout when a user is signed in" do
      user = User.create!(
        first_name: "Signed",
        last_name: "User",
        email: "signed-events@example.com",
        password: "password"
      )

      sign_in user
      get events_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("tom-public")
      expect(response.body).to include("tom-site-header")
      expect(response.body).to include("Upcoming Events")
    end
  end

  describe "GET /events/:id" do
    it "returns http success" do
      event = Event.create!(
        title: "Youth Camp",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :free
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
    end

    it "shows all state camp details for camp information events" do
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("State Camp Details")
      expect(response.body).to include("Choose Your State")
      expect(response.body).to include("Abia")
      expect(response.body).to include("Zamfara")
      expect(response.body.scan("data-camp-state").size).to eq(37)
    end

    it "renders an event without schedule or location details" do
      event = Event.create!(
        title: "Undated Camp",
        event_type: :information
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Date TBA")
      expect(response.body).to include("Time TBA")
    end

    it "includes saved area camp details in the modal payload" do
      state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
      area = Area.create!(name: "Asaba Central", state: state)
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )
      event.camp_details.create!(
        state_name: "Delta",
        area: area,
        registration_link: "https://example.com/delta-camp",
        notes: "Bring your Bible.",
        position: 9
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Asaba Central")
      expect(response.body).to include("Bring your Bible.")
      expect(response.body).to include("https://example.com/delta-camp")
    end

    it "includes multiple camp areas for one state in the modal payload" do
      state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
      agbor = Area.create!(name: "Agbor Camp", state: state)
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )
      event.camp_details.create!(
        state_name: "Delta",
        notes: "Main camp details.",
        registration_link: "https://example.com/main-camp",
        position: 1
      )
      event.camp_details.create!(
        state_name: "Delta",
        area: agbor,
        notes: "Agbor camp details.",
        registration_link: "https://example.com/agbor-camp",
        position: 2
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Main Camp")
      expect(response.body).to include("Main camp details.")
      expect(response.body).to include("https://example.com/main-camp")
      expect(response.body).to include("Agbor Camp")
      expect(response.body).to include("Agbor camp details.")
      expect(response.body).to include("https://example.com/agbor-camp")
      expect(response.body).to include("data-camp-modal-next")
    end

    it "does not show state camp details for other information events" do
      event = Event.create!(
        title: "National Awareness Briefing",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).not_to include("State Camp Details")
      expect(response.body).not_to include("data-camp-state")
    end
  end
end
