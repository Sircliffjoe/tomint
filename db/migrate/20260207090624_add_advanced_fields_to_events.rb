class AddAdvancedFieldsToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :price, :decimal
    add_column :events, :currency, :string
    add_column :events, :event_type, :integer
  end
end
