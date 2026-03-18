class CreateStates < ActiveRecord::Migration[8.1]
  def change
    create_table :states do |t|
      t.string :name
      t.string :code
      t.string :country
      t.integer :status
      t.text :contact_info

      t.timestamps
    end
  end
end
