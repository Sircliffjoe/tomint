class CreateDonations < ActiveRecord::Migration[8.1]
  def change
    create_table :donations do |t|
      t.decimal :amount
      t.string :currency
      t.string :donor_email
      t.string :purpose
      t.string :payment_reference
      t.integer :status

      t.timestamps
    end
  end
end
