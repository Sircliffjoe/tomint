class RemoveRedundantFieldsFromCampDetails < ActiveRecord::Migration[8.1]
  def change
    remove_column :camp_details, :date, :string
    remove_column :camp_details, :venue, :string
    remove_column :camp_details, :contact, :string
  end
end
