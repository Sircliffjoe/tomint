class CreateCampDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :camp_details do |t|
      t.references :event, null: false, foreign_key: true
      t.string :state_name, null: false
      t.string :date
      t.string :venue
      t.string :contact
      t.text :notes
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :camp_details, [ :event_id, :state_name ], unique: true
  end
end
