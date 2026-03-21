class CreateAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.text :description
      t.references :state, null: false, foreign_key: true
      t.bigint :area_leader_id

      t.timestamps
    end
    add_index :areas, :area_leader_id
    add_foreign_key :areas, :users, column: :area_leader_id
  end
end
