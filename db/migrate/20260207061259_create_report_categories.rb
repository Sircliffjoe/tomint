class CreateReportCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :report_categories do |t|
      t.string :name
      t.belongs_to :directorate, null: true, foreign_key: true

      t.timestamps
    end
  end
end
