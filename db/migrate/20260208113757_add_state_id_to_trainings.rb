class AddStateIdToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_reference :trainings, :state, null: true, foreign_key: true
  end
end
