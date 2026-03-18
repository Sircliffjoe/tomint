class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.belongs_to :state, null: true, foreign_key: true
      t.boolean :registration_open

      t.timestamps
    end
  end
end
