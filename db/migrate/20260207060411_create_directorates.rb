class CreateDirectorates < ActiveRecord::Migration[8.1]
  def change
    create_table :directorates do |t|
      t.string :name
      t.integer :director_user_id

      t.timestamps
    end
    add_index :directorates, :director_user_id
  end
end
