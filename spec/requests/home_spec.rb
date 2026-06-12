require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    it "returns http success and displays the search form" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Find an event or training")
      expect(response.body).to include("Search")
    end
  end

  describe "GET /search" do
    it "returns matching upcoming events and trainings" do
      event = Event.create!(
        title: "Leadership Camp",
        start_time: 1.week.from_now,
        end_time: 1.week.from_now + 2.hours,
        location: "Lagos",
        event_type: :free
      )
      past_event = Event.create!(
        title: "Leadership Retreat",
        start_time: 1.week.ago,
        end_time: 1.week.ago + 2.hours,
        location: "Abuja",
        event_type: :free
      )
      training = Training.create!(
        title: "Foundations of Leadership",
        category: "Leadership",
        description: "Worker formation"
      )
      TrainingSession.create!(
        training: training,
        title: "Leadership Practice",
        media_url: "https://example.com/session"
      )

      get search_path, params: { q: "leadership" }

      expect(response).to have_http_status(:success)
      expect(response.body).to include(event.title)
      expect(response.body).not_to include(past_event.title)
      expect(response.body).to include(training.title)
    end
  end
end
