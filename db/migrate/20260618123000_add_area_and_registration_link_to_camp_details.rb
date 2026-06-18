class AddAreaAndRegistrationLinkToCampDetails < ActiveRecord::Migration[8.1]
  def change
    remove_index :camp_details, [ :event_id, :state_name ]

    add_column :camp_details, :area_name, :string
    add_column :camp_details, :registration_link, :string

    add_index :camp_details, [ :event_id, :state_name, :position ], name: "index_camp_details_on_event_state_position"
  end
end
