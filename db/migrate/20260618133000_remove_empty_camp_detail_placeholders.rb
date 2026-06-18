class RemoveEmptyCampDetailPlaceholders < ActiveRecord::Migration[8.1]
  DEFAULT_NOTES = [
    "Camp details will be updated once the state flyer is ready.",
    "Camp details will be updated once the FCT flyer is ready."
  ].freeze

  def up
    CampDetail.left_outer_joins(:flyer_attachment)
              .where(area_id: nil, registration_link: [ nil, "" ])
              .where("camp_details.notes IS NULL OR camp_details.notes = '' OR camp_details.notes IN (?)", DEFAULT_NOTES)
              .where(active_storage_attachments: { id: nil })
              .delete_all
  end

  def down
    # Empty placeholder CampDetail rows are regenerated in the admin form when needed.
  end
end
