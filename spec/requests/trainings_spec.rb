require 'rails_helper'

RSpec.describe "Trainings", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/trainings/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/trainings/show"
      expect(response).to have_http_status(:success)
    end
  end

end
