class CreateTrainingSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :training_sessions do |t|
      t.belongs_to :training, null: false, foreign_key: true
      t.string :title
      t.string :media_url
      t.integer :duration

      t.timestamps
    end
  end
end
