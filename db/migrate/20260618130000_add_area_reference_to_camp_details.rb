class AddAreaReferenceToCampDetails < ActiveRecord::Migration[8.1]
  def change
    add_reference :camp_details, :area, null: true, foreign_key: true
  end
end
