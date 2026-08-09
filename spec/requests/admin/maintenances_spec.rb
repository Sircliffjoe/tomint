require 'rails_helper'

RSpec.describe 'Admin::Maintenances', type: :request do
  let(:super_admin) do
    User.create!(
      first_name: 'Super',
      last_name: 'Admin',
      email: 'admin@example.com',
      password: 'password123',
      role: :super_admin
    )
  end

  let(:regular_user) do
    User.create!(
      first_name: 'John',
      last_name: 'Doe',
      email: 'user@example.com',
      password: 'password123',
      role: :public_user
    )
  end

  before do
    SystemSetting.destroy_all
    Rails.cache.clear
  end

  describe 'GET /admin/maintenance' do
    context 'when signed in as super admin' do
      before { sign_in super_admin }

      it 'returns http success' do
        get admin_maintenance_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Platform Maintenance Mode')
      end
    end

    context 'when signed in as regular user' do
      before { sign_in regular_user }

      it 'redirects with authorization alert' do
        get admin_maintenance_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when guest' do
      it 'redirects to sign in' do
        get admin_maintenance_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /admin/maintenance/toggle' do
    before { sign_in super_admin }

    it 'enables maintenance mode when currently disabled' do
      expect(SystemSetting.maintenance_mode?).to be false
      post toggle_admin_maintenance_path
      expect(SystemSetting.maintenance_mode?).to be true
      expect(flash[:notice]).to include('ENABLED')
    end

    it 'disables maintenance mode when currently enabled' do
      SystemSetting.enable_maintenance!
      post toggle_admin_maintenance_path
      expect(SystemSetting.maintenance_mode?).to be false
      expect(flash[:notice]).to include('DISABLED')
    end
  end

  describe 'PATCH /admin/maintenance' do
    before { sign_in super_admin }

    it 'updates maintenance settings and toggles when requested' do
      patch admin_maintenance_path, params: {
        maintenance_message: 'Custom maintenance message test',
        toggle: 'enable'
      }

      expect(SystemSetting.maintenance_mode?).to be true
      expect(SystemSetting.maintenance_message).to eq('Custom maintenance message test')
      expect(response).to redirect_to(admin_maintenance_path)
    end
  end
end
