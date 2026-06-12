class CreateTrainingRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :training_registrations do |t|
      t.belongs_to :training, null: false, foreign_key: true
      t.belongs_to :user, null: true, foreign_key: true
      t.string :guest_name, null: false
      t.string :guest_email, null: false
      t.string :guest_phone

      t.timestamps
    end
  end
end
