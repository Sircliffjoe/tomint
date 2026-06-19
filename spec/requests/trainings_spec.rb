require 'rails_helper'

RSpec.describe "Trainings", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /trainings" do
    it "returns http success" do
      get trainings_path

      expect(response).to have_http_status(:success)
    end

    it "uses the public layout when a user is signed in" do
      user = User.create!(
        first_name: "Signed",
        last_name: "User",
        email: "signed-trainings@example.com",
        password: "password"
      )

      sign_in user
      get trainings_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("tom-public")
      expect(response.body).to include("tom-site-header")
      expect(response.body).to include("Training Resources")
    end
  end

  describe "GET /trainings/:id" do
    it "returns http success" do
      training = Training.create!(
        title: "Foundations of Leadership",
        category: "Leadership",
        description: "Worker formation"
      )

      get training_path(training)

      expect(response).to have_http_status(:success)
    end

    it "uses a slug in generated training URLs" do
      training = Training.create!(
        title: "Effective Evangelism",
        category: "Evangelism",
        description: "Outreach formation"
      )

      expect(training_path(training)).to eq("/trainings/effective-evangelism")

      get training_path(training)

      expect(response).to have_http_status(:success)
    end

    it "keeps old numeric training URLs working" do
      training = Training.create!(
        title: "Legacy Training URL",
        category: "Leadership",
        description: "Worker formation"
      )

      get "/trainings/#{training.id}"

      expect(response).to have_http_status(:success)
    end
  end
end
