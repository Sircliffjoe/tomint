class AddAdvancedFieldsToRegistrations < ActiveRecord::Migration[8.1]
  def change
    add_column :registrations, :payment_reference, :string
    add_column :registrations, :amount_paid, :decimal
    add_column :registrations, :qr_code_token, :string
  end
end
