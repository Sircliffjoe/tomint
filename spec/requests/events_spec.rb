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
  end
end
