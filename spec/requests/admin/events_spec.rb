require 'rails_helper'

RSpec.describe "Admin events", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) do
    User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin-events@example.com",
      password: "password",
      role: :super_admin
    )
  end

  before do
    sign_in admin
  end

  describe "POST /admin/events" do
    it "opens the editor for camp information events without creating empty placeholder details" do
      post admin_events_path, params: {
        event: {
          title: "TOM Camp 2026",
          start_time: 1.week.from_now,
          end_time: 1.week.from_now + 2.hours,
          event_type: "information"
        }
      }

      event = Event.find_by!(title: "TOM Camp 2026")

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(event.camp_details.count).to eq(0)
    end

    it "does not create camp details for ordinary information events" do
      post admin_events_path, params: {
        event: {
          title: "National Briefing",
          start_time: 1.week.from_now,
          end_time: 1.week.from_now + 2.hours,
          event_type: "information"
        }
      }

      event = Event.find_by!(title: "National Briefing")

      expect(response).to redirect_to(admin_events_path)
      expect(event.camp_details.count).to eq(0)
    end
  end

  describe "GET /admin/events/:id/edit" do
    it "renders the tabbed camp editor with an add area button" do
      state = State.create!(name: "Lagos", code: "LAG", country: "Nigeria")
      Area.create!(name: "Ikorodu Area", state: state)
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      get edit_admin_event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('data-camp-admin-editor')
      expect(response.body).to include('data-camp-admin-tab="lagos"')
      expect(response.body).to include('data-camp-add-area="lagos"')
      expect(response.body).to include("Manage Areas")
      expect(response.body).to include("Ikorodu Area")
      expect(response.body.scan('value="Update Event"').size).to eq(1)
      expect(response.body).to include("event[camp_details_attributes][2400][state_name]")
      expect(response.body).not_to include("event[camp_details_attributes][lagos-0-new]")
    end
  end

  describe "PATCH /admin/events/:id" do
    it "updates state camp details" do
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )
      state = State.create!(name: "Lagos", code: "LAG", country: "Nigeria")
      area = Area.create!(name: "Mainland Area", state: state)

      patch admin_event_path(event), params: {
        event: {
          title: event.title,
          start_time: event.start_time,
          end_time: event.end_time,
          event_type: "information",
          camp_details_attributes: {
            "0" => {
              state_name: "Lagos",
              position: 24,
              area_id: area.id,
              registration_link: "https://example.com/lagos-camp",
              notes: "Come prepared."
            }
          }
        }
      }

      lagos = event.camp_details.find_by!(state_name: "Lagos")

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(lagos.area).to eq(area)
      expect(lagos.area_label).to eq("Mainland Area")
      expect(lagos.registration_link).to eq("https://example.com/lagos-camp")
      expect(lagos.notes).to eq("Come prepared.")
    end

    it "adds another area for a state" do
      state = State.create!(name: "Lagos", code: "LAG", country: "Nigeria")
      area = Area.create!(name: "Ikorodu Area", state: state)
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      patch admin_event_path(event), params: {
        event: {
          title: event.title,
          start_time: event.start_time,
          end_time: event.end_time,
          event_type: "information",
          camp_details_attributes: {
            "0" => {
              state_name: "Lagos",
              position: 24,
              area_id: area.id,
              registration_link: "https://example.com/ikorodu-camp",
              notes: "Area-specific camp."
            }
          }
        }
      }

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(event.camp_details.where(state_name: "Lagos").map(&:area_label)).to include("Ikorodu Area")
    end

    it "saves main camp and area camp details for the same state" do
      state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
      agbor = Area.create!(name: "Agbor", state: state)
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )

      patch admin_event_path(event), params: {
        event: {
          title: event.title,
          event_type: "information",
          camp_details_attributes: {
            "900" => {
              state_name: "Delta",
              position: 9,
              area_id: "",
              registration_link: "https://example.com/delta-main",
              notes: "Main Delta camp."
            },
            "90001718756123456" => {
              state_name: "Delta",
              position: 9,
              area_row: "1",
              area_id: agbor.id,
              registration_link: "https://example.com/delta-agbor",
              notes: "Agbor Delta camp."
            }
          }
        }
      }

      event.reload
      delta_details = event.camp_details.where(state_name: "Delta")

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(delta_details.map(&:area_label)).to contain_exactly("Main Camp", "Agbor")
      expect(delta_details.find { |detail| detail.area_id.blank? }.notes).to eq("Main Delta camp.")
      expect(delta_details.find { |detail| detail.area == agbor }.registration_link).to eq("https://example.com/delta-agbor")
    end
  end
end
