class AddPasswordPolicyFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :must_change_password, :boolean, null: false, default: false
    add_column :users, :password_changed_at, :datetime
  end
end
