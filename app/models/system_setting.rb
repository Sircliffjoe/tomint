class SystemSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Fetch value for a key with caching
  def self.get(key, default = nil)
    return default.to_s unless table_exists_safe?

    Rails.cache.fetch("system_setting/#{key}", expires_in: 5.minutes) do
      find_by(key: key.to_s)&.value.presence || default.to_s
    end
  rescue StandardError
    default.to_s
  end

  # Set value for a key and invalidate cache
  def self.set(key, value, description: nil)
    return unless table_exists_safe?

    setting = find_or_initialize_by(key: key.to_s)
    setting.value = value.to_s
    setting.description = description if description.present?
    setting.save!
    begin
      Rails.cache.write("system_setting/#{key}", setting.value)
    rescue StandardError => e
      Rails.logger.error("SystemSetting cache write failed for #{key}: #{e.message}")
    end
    setting.value
  end

  # Check if maintenance mode is active
  def self.maintenance_mode?
    get("maintenance_mode", "false") == "true"
  end

  # Enable maintenance mode with optional custom message and completion time
  def self.enable_maintenance!(message: nil, end_time: nil)
    set("maintenance_mode", "true", description: "Platform maintenance mode switch")
    set("maintenance_message", message.presence || default_maintenance_message, description: "Maintenance mode message for users")
    set("maintenance_end_time", end_time.presence || "", description: "Estimated completion time")
  end

  # Disable maintenance mode
  def self.disable_maintenance!
    set("maintenance_mode", "false", description: "Platform maintenance mode switch")
  end

  # Custom or default maintenance message
  def self.maintenance_message
    msg = get("maintenance_message", default_maintenance_message)
    msg.presence || default_maintenance_message
  end

  # Estimated end time if set
  def self.maintenance_end_time
    val = get("maintenance_end_time", "")
    return nil if val.blank?

    Time.zone.parse(val) rescue nil
  end

  def self.default_maintenance_message
    "We are currently performing scheduled maintenance to improve our platform services. Please check back shortly."
  end

  def self.ask_headline
    get("ask_headline", "You can ask. We will listen.")
  end

  def self.ask_intro_text
    get("ask_intro_text", "You don't need to have the right words. Ask us about something you're struggling with, something you don't understand, or something that's bothering you. You can remain completely anonymous.")
  end

  def self.ask_privacy_notice
    get("ask_privacy_notice", "Your privacy matters to us. You don't have to provide your name or contact information to ask a question. However, if you tell us that you or someone else may be in serious danger, TOM may need to take appropriate steps to help protect you or someone else.")
  end

  def self.ask_urgent_help_text
    get("ask_urgent_help_text", "If you are in immediate danger or distress, our trained safeguarding team is here for you. We treat every urgent concern with highest priority and confidentiality.")
  end

  def self.table_exists_safe?
    connection.table_exists?("system_settings")
  rescue StandardError
    false
  end
end
