class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :state, optional: true
  belongs_to :directorate, optional: true

  enum :role, {
    super_admin: 0,
    directorate_director: 1,
    state_admin: 2,
    state_secretary: 3,
    public_user: 4
  }, default: :public_user

  validates :first_name, :last_name, presence: true
  validates :state_id, presence: true, if: -> { state_admin? || state_secretary? }
  validates :directorate_id, presence: true, if: :directorate_director?
end
