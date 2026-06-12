require 'rails_helper'

RSpec.describe "Disabled signup", type: :request do
  it "does not expose the public signup route" do
    get "/users/sign_up"

    expect(response).to have_http_status(:not_found)
  end
end
