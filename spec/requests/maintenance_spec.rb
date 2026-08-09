require 'rails_helper'

RSpec.describe 'System Maintenance Mode Enforcement', type: :request do
  let(:super_admin) do
    User.create!(
      first_name: 'Super',
      last_name: 'Admin',
      email: 'superadmin@example.com',
      password: 'password123',
      role: :super_admin
    )
  end

  let(:state_coordinator) do
    country = Country.create!(name: 'Nigeria', code: 'NG', slug: 'nigeria')
    zone = Zone.create!(name: 'South West', country: country)
    state = State.create!(name: 'Lagos', code: 'LA', country: country, zone: zone)
    User.create!(
      first_name: 'State',
      last_name: 'Coord',
      email: 'coord@example.com',
      password: 'password123',
      role: :state_coordinator,
      state: state
    )
  end

  let(:regular_user) do
    User.create!(
      first_name: 'Jane',
      last_name: 'User',
      email: 'jane@example.com',
      password: 'password123',
      role: :public_user
    )
  end

  before do
    SystemSetting.destroy_all
    Rails.cache.clear
  end

  context 'when maintenance mode is OFF' do
    it 'allows guests to visit root path' do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it 'allows regular users to visit dashboard' do
      sign_in regular_user
      get dashboard_path
      expect(response).to redirect_to(reports_path)
    end
  end

  context 'when maintenance mode is ON' do
    before do
      SystemSetting.enable_maintenance!(message: 'Scheduled maintenance in progress.')
    end

    it 'blocks guest access to root path and returns 503 Service Unavailable' do
      get root_path
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include('System Under Maintenance')
      expect(response.body).to include('Scheduled maintenance in progress.')
    end

    it 'blocks guest access to public pages' do
      get about_path
      expect(response).to have_http_status(:service_unavailable)
    end

    it 'blocks regular user access to dashboard' do
      sign_in regular_user
      get dashboard_path
      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to include('System Under Maintenance')
      expect(response.body).to include('Logged in as')
      expect(response.body).to include(regular_user.email)
    end

    it 'blocks state coordinator access' do
      sign_in state_coordinator
      get states_dashboard_path
      expect(response).to have_http_status(:service_unavailable)
    end

    it 'returns JSON 503 error for API/JSON requests' do
      get root_path, headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:service_unavailable)
      json = JSON.parse(response.body)
      expect(json['maintenance']).to be true
      expect(json['message']).to include('Scheduled maintenance in progress.')
    end

    it 'allows Super Admin user full access to admin pages and site' do
      sign_in super_admin
      get admin_dashboard_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('MAINTENANCE MODE IS ACTIVE')
    end

    it 'allows access to health check' do
      get rails_health_check_path
      expect(response).to have_http_status(:success)
    end

    it 'allows access to sign in page so Super Admin can sign in' do
      get new_user_session_path
      expect(response).to have_http_status(:success)
    end
  end
end
