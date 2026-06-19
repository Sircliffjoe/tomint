class User < ApplicationRecord
  has_one_attached :avatar

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  belongs_to :state, optional: true
  belongs_to :directorate, optional: true
  has_many :sent_internal_messages, class_name: "InternalMessage", foreign_key: :sender_id, dependent: :destroy, inverse_of: :sender
  has_many :received_internal_messages, class_name: "InternalMessage", foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient

  enum :role, {
    super_admin: 0,
    directorate_director: 1,
    state_coordinator: 2,
    state_secretary: 3,
    public_user: 4
  }, default: :public_user

  ROLE_DISPLAY_NAMES = {
    "super_admin" => "Super Admin",
    "directorate_director" => "Director",
    "state_coordinator" => "State Coordinator",
    "state_secretary" => "State Secretary",
    "public_user" => "User"
  }.freeze

  def self.generate_temporary_password
    "#{SecureRandom.alphanumeric(4)}-#{SecureRandom.alphanumeric(4)}-#{SecureRandom.alphanumeric(4)}"
  end

  def display_role
    ROLE_DISPLAY_NAMES[role] || role.humanize
  end

  def self.role_options_for_select
    roles.keys.map { |r| [ ROLE_DISPLAY_NAMES[r] || r.humanize, r ] }
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name&.first}#{last_name&.first}".upcase
  end

  def mark_password_changed!
    self.must_change_password = false
    self.password_changed_at = Time.current
  end

  validates :first_name, :last_name, presence: true
  validates :state_id, presence: true, if: -> { state_coordinator? || state_secretary? }
  validates :directorate_id, presence: true, if: :directorate_director?
end
