class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.string :title
      t.integer :status
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :state, null: false, foreign_key: true
      t.belongs_to :directorate, null: false, foreign_key: true
      t.belongs_to :report_category, null: false, foreign_key: true
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.datetime :approved_at

      t.timestamps
    end
  end
end
