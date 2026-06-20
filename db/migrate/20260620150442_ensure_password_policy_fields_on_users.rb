class EnsurePasswordPolicyFieldsOnUsers < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:users, :must_change_password)
      add_column :users, :must_change_password, :boolean, null: false, default: false
    end

    unless column_exists?(:users, :password_changed_at)
      add_column :users, :password_changed_at, :datetime
    end
  end
end
