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
      expect(response.body).to include("data-camp-admin-tab=\"state-#{state.id}\"")
      expect(response.body).to include("data-camp-add-area=\"state-#{state.id}\"")
      expect(response.body).to include("Manage Areas")
      expect(response.body).to include("Ikorodu Area")
      expect(response.body.scan('value="Update Event"').size).to eq(1)
      expect(response.body).to include("event[camp_details_attributes][0][state_id]")
      expect(response.body).to include("event[camp_details_attributes][0][state_name]")
      expect(response.body).to include("event[camp_details_attributes][0][formatted_notes]")
      expect(response.body).to include("trix-editor")
      expect(response.body).not_to include("event[camp_details_attributes][lagos-0-new]")
    end

    it "groups camp editor locations by country" do
      nigeria = Country.find_or_create_by!(name: "Nigeria", code: "NG")
      ghana = Country.create!(name: "Ghana", code: "GH")
      lagos = State.create!(name: "Lagos", code: "LAG", country: nigeria)
      greater_accra = State.create!(name: "Greater Accra", code: "GAR", country: ghana)
      event = Event.create!(
        title: "TOM Camp 2026",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      get edit_admin_event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("data-camp-country-tab=\"country-#{nigeria.id}\"")
      expect(response.body).to include("data-camp-country-tab=\"country-#{ghana.id}\"")
      expect(response.body).to include("href=\"#camp-country-panel-country-#{ghana.id}\"")
      expect(response.body).to include("data-camp-country-panel=\"country-#{ghana.id}\"")
      expect(response.body).to include("data-camp-admin-tab=\"state-#{lagos.id}\"")
      expect(response.body).to include("data-camp-admin-tab=\"state-#{greater_accra.id}\"")
      expect(response.body).to include("Greater Accra")
    end

    it "renders the camp editor before the camp detail state reference migration is present" do
      allow(CampDetail).to receive(:state_reference_available?).and_return(false)
      state = State.create!(name: "Edo", code: "EDO", country: "Nigeria")
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )

      get edit_admin_event_path(event)

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Edo")
      expect(response.body).to include("event[camp_details_attributes][0][state_name]")
      expect(response.body).not_to include("event[camp_details_attributes][0][state_id]")
    end

    it "redirects state coordinators away from national events they cannot edit" do
      state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
      coordinator = User.create!(
        first_name: "State",
        last_name: "Coordinator",
        email: "event-state-coordinator@example.com",
        password: "password",
        role: :state_coordinator,
        state: state
      )
      event = Event.create!(
        title: "National Youth Conference 2027",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      sign_in coordinator
      get edit_admin_event_path(event)

      expect(response).to redirect_to(states_dashboard_path)
      expect(flash[:alert]).to eq("You are not allowed to perform that action.")
    end
  end

  describe "GET /admin/events" do
    it "hides edit and delete actions for view-only national events" do
      state = State.create!(name: "Delta", code: "DEL", country: "Nigeria")
      coordinator = User.create!(
        first_name: "State",
        last_name: "Coordinator",
        email: "event-index-coordinator@example.com",
        password: "password",
        role: :state_coordinator,
        state: state
      )
      event = Event.create!(
        title: "National Youth Conference 2027",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        event_type: :information
      )

      sign_in coordinator
      get admin_events_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("National Youth Conference 2027")
      expect(response.body).to include("View only")
      expect(response.body).not_to include(edit_admin_event_path(event))
      expect(response.body).not_to include(%(action="#{admin_event_path(event)}"))
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

    it "stores the selected state reference for camp details" do
      ghana = Country.create!(name: "Ghana", code: "GH")
      greater_accra = State.create!(name: "Greater Accra", code: "GA", country: ghana)
      event = Event.create!(
        title: "TOM Camp 2026",
        event_type: :information
      )

      patch admin_event_path(event), params: {
        event: {
          title: event.title,
          event_type: "information",
          camp_details_attributes: {
            "0" => {
              state_id: greater_accra.id,
              state_name: "Greater Accra",
              position: 0,
              area_id: "",
              notes: "Ghana camp details."
            }
          }
        }
      }

      detail = event.reload.camp_details.find_by!(state: greater_accra)

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(detail.state_name).to eq("Greater Accra")
      expect(detail.notes).to eq("Ghana camp details.")
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

    it "saves rich text camp notes" do
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
              formatted_notes: "<div><strong>Bring your Bible</strong><br>Come expectant.</div>"
            }
          }
        }
      }

      camp_detail = event.reload.camp_details.find_by!(state_name: "Delta")

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(camp_detail.formatted_notes.to_plain_text).to include("Bring your Bible")
      expect(camp_detail.public_notes_html).to include("<strong>Bring your Bible</strong>")
    end

    it "does not create duplicate main camp details for a state" do
      state = State.create!(name: "Edo", code: "EDO", country: "Nigeria")
      event = Event.create!(title: "TOM Camp 2026", event_type: :information)
      event.camp_details.create!(state: state, state_name: "Edo", notes: "Existing Edo camp.")

      patch admin_event_path(event), params: {
        event: {
          title: event.title,
          event_type: "information",
          camp_details_attributes: {
            "0" => {
              state_id: state.id,
              state_name: "Edo",
              position: 1,
              area_id: "",
              notes: "Duplicate Edo camp."
            }
          }
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(event.reload.camp_details.where(state_name: "Edo", area_id: nil).count).to eq(1)
    end
  end

  describe "PATCH /admin/events/:id/deduplicate_camp_details" do
    it "clears duplicate main camp entries while keeping the most complete entry" do
      state = State.create!(name: "Edo", code: "EDO", country: "Nigeria")
      event = Event.create!(title: "TOM Camp 2026", event_type: :information)
      CampDetail.insert_all!([
        {
          event_id: event.id,
          state_id: nil,
          state_name: "Edo",
          registration_link: nil,
          notes: "Old legacy row.",
          position: 1,
          created_at: 2.days.ago,
          updated_at: 2.days.ago
        },
        {
          event_id: event.id,
          state_id: state.id,
          state_name: "Edo",
          registration_link: "https://example.com/edo",
          notes: "Complete row.",
          position: 1,
          created_at: 1.day.ago,
          updated_at: 1.day.ago
        }
      ])

      patch deduplicate_camp_details_admin_event_path(event)

      edo_details = event.reload.camp_details.where(state_name: "Edo")

      expect(response).to redirect_to(edit_admin_event_path(event))
      expect(edo_details.count).to eq(1)
      expect(edo_details.first.registration_link).to eq("https://example.com/edo")
    end
  end
end
