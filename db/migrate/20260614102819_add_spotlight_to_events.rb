class AddSpotlightToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :spotlight, :boolean, default: false
  end
end
