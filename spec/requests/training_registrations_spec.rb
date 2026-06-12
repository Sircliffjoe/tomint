require 'rails_helper'

RSpec.describe "Training registrations", type: :request do
  describe "POST /trainings/:training_id/registrations" do
    it "allows guest registration for trainings" do
      training = Training.create!(
        title: "Foundations of Leadership",
        category: "Leadership",
        description: "Worker formation"
      )

      expect {
        post training_training_registrations_path(training), params: {
          training_registration: {
            guest_name: "Guest Trainee",
            guest_email: "trainee@example.com",
            guest_phone: "08000000000"
          }
        }
      }.to change(TrainingRegistration, :count).by(1)

      expect(response).to redirect_to(training_path(training))
      expect(TrainingRegistration.last.user).to be_nil
      expect(TrainingRegistration.last.guest_email).to eq("trainee@example.com")
    end
  end
end
