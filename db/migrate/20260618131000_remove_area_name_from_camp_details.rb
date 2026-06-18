class RemoveAreaNameFromCampDetails < ActiveRecord::Migration[8.1]
  def change
    remove_column :camp_details, :area_name, :string
  end
end
