require 'rails_helper'

RSpec.describe "TrainingSessions", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/training_sessions/show"
      expect(response).to have_http_status(:success)
    end
  end

end
