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

    it "uses a slug in generated event URLs" do
      event = Event.create!(
        title: "National Youth Conference 2027",
        event_type: :information
      )

      expect(event_path(event)).to eq("/events/national-youth-conference-2027")

      get event_path(event)

      expect(response).to have_http_status(:success)
    end

    it "keeps old numeric event URLs working" do
      event = Event.create!(
        title: "Legacy Event URL",
        event_type: :information
      )

      get "/events/#{event.id}"

      expect(response).to have_http_status(:success)
    end

    it "shows CMS state camp details for camp information events" do
      Country.find_or_create_by!(name: "Nigeria", code: "NG")
      State.create!(name: "Abia", code: "ABI", country: "Nigeria")
      State.create!(name: "Zamfara", code: "ZAM", country: "Nigeria")
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Camp Details")
      expect(response.body).to include("Choose Your Location")
      expect(response.body).to include("Nigeria")
      expect(response.body).to include("Abia")
      expect(response.body).to include("Zamfara")
      expect(response.body.scan("data-camp-state").size).to eq(2)
    end

    it "shows international CMS locations for camp information events" do
      ghana = Country.create!(name: "Ghana", code: "GH")
      State.create!(name: "Greater Accra", code: "GA", country: ghana)
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Ghana")
      expect(response.body).to include("Greater Accra")
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

    it "includes rich text camp notes in the modal payload" do
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )
      camp_detail = event.camp_details.create!(
        state_name: "Delta",
        registration_link: "https://example.com/delta-camp",
        position: 9
      )
      camp_detail.update!(formatted_notes: "<div><strong>Important:</strong> Come expectant.</div>")

      get event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("notesHtml")
      expect(response.body).to include("Important:")
      expect(response.body).to include("Come expectant.")
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
