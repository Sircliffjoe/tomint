class AddDescriptionToDirectorates < ActiveRecord::Migration[8.1]
  def change
    add_column :directorates, :description, :text
  end
end
