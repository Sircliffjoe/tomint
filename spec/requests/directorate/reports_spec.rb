require 'rails_helper'

RSpec.describe "Directorate::Reports", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/directorate/reports/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/directorate/reports/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /review" do
    it "returns http success" do
      get "/directorate/reports/review"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve" do
    it "returns http success" do
      get "/directorate/reports/approve"
      expect(response).to have_http_status(:success)
    end
  end

end
