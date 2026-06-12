class AllowGuestEventRegistrations < ActiveRecord::Migration[8.1]
  def change
    change_column_null :registrations, :user_id, true
    add_column :registrations, :guest_name, :string
    add_column :registrations, :guest_email, :string
    add_column :registrations, :guest_phone, :string
  end
end
