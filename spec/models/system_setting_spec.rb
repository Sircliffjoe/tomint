require 'rails_helper'

RSpec.describe SystemSetting, type: :model do
  before do
    SystemSetting.destroy_all
    Rails.cache.clear
  end

  describe '.maintenance_mode?' do
    it 'returns false by default' do
      expect(SystemSetting.maintenance_mode?).to be false
    end

    it 'returns true when maintenance mode is enabled' do
      SystemSetting.enable_maintenance!
      expect(SystemSetting.maintenance_mode?).to be true
    end

    it 'returns false after maintenance mode is disabled' do
      SystemSetting.enable_maintenance!
      SystemSetting.disable_maintenance!
      expect(SystemSetting.maintenance_mode?).to be false
    end
  end

  describe '.enable_maintenance!' do
    it 'sets custom message and end_time' do
      end_time = 2.hours.from_now
      SystemSetting.enable_maintenance!(
        message: 'Upgrading database servers',
        end_time: end_time.iso8601
      )

      expect(SystemSetting.maintenance_mode?).to be true
      expect(SystemSetting.maintenance_message).to eq('Upgrading database servers')
      expect(SystemSetting.maintenance_end_time).to be_within(2.seconds).of(end_time)
    end
  end

  describe '.get and .set' do
    it 'stores and retrieves arbitrary key value pairs with cache update' do
      SystemSetting.set('custom_key', 'custom_value')
      expect(SystemSetting.get('custom_key')).to eq('custom_value')
    end

    it 'works when solid_cache_store is active' do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(:solid_cache_store))
      expect { SystemSetting.set('cache_test_key', 'cache_test_val') }.not_to raise_error
      expect(SystemSetting.get('cache_test_key')).to eq('cache_test_val')
    end
  end
end
