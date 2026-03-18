class CreateTrainings < ActiveRecord::Migration[8.1]
  def change
    create_table :trainings do |t|
      t.string :title
      t.text :description
      t.string :category

      t.timestamps
    end
  end
end
