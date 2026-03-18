require 'rails_helper'

RSpec.describe "Donations", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/donations/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/donations/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /thank_you" do
    it "returns http success" do
      get "/donations/thank_you"
      expect(response).to have_http_status(:success)
    end
  end

end
