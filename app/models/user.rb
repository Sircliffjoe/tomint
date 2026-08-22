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

  has_many :ask_responses, dependent: :nullify
  has_many :ask_assignments, foreign_key: :assignee_id, dependent: :nullify, inverse_of: :assignee
  has_many :assigned_questions, through: :ask_assignments, source: :ask_question
  has_many :ask_internal_notes, dependent: :nullify
  has_many :ask_moderation_actions, dependent: :nullify
  has_many :created_live_sessions, class_name: "AskLiveSession", foreign_key: :created_by_id, dependent: :nullify, inverse_of: :created_by
  has_many :assigned_safeguarding_escalations, class_name: "AskEscalation", foreign_key: :assigned_safeguarding_lead_id, dependent: :nullify, inverse_of: :assigned_safeguarding_lead

  enum :role, {
    super_admin: 0,
    directorate_director: 1,
    state_coordinator: 2,
    state_secretary: 3,
    public_user: 4,
    ask_moderator: 5,
    ask_responder: 6,
    safeguarding_lead: 7
  }, default: :public_user

  ROLE_DISPLAY_NAMES = {
    "super_admin" => "Super Admin",
    "directorate_director" => "Director",
    "state_coordinator" => "State Coordinator",
    "state_secretary" => "State Secretary",
    "public_user" => "User",
    "ask_moderator" => "TOM ASK Moderator",
    "ask_responder" => "TOM ASK Responder",
    "safeguarding_lead" => "Safeguarding Lead"
  }.freeze

  def can_moderate_ask?
    super_admin? || ask_moderator? || safeguarding_lead?
  end

  def can_respond_ask?
    super_admin? || ask_moderator? || ask_responder? || safeguarding_lead?
  end

  def can_access_safeguarding?
    super_admin? || safeguarding_lead?
  end

  def can_manage_live_sessions?
    super_admin? || ask_moderator? || directorate_director? || state_coordinator?
  end

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
