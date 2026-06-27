class AddStateReferenceToCampDetails < ActiveRecord::Migration[8.1]
  def up
    add_reference :camp_details, :state, foreign_key: true

    execute(<<~SQL.squish)
      UPDATE camp_details
      SET state_id = states.id
      FROM states
      INNER JOIN countries ON countries.id = states.country_id
      WHERE camp_details.state_id IS NULL
        AND camp_details.state_name = states.name
        AND countries.code = 'NG'
    SQL

    add_index :camp_details, [ :event_id, :state_id, :position ]
  end

  def down
    remove_index :camp_details, [ :event_id, :state_id, :position ]
    remove_reference :camp_details, :state, foreign_key: true
  end
end
