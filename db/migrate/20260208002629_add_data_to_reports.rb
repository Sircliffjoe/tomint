class AddDataToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :data, :jsonb
  end
end
