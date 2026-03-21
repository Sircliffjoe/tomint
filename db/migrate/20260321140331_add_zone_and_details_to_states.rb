class AddZoneAndDetailsToStates < ActiveRecord::Migration[8.1]
  def change
    add_column :states, :zone_id, :bigint
    add_column :states, :year_created, :integer
    add_column :states, :description, :text
    add_index :states, :zone_id
    add_foreign_key :states, :zones
  end
end
