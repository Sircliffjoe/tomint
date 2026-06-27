class RestoreNigeriaFctLocation < ActiveRecord::Migration[8.1]
  def up
    nigeria = Country.find_or_create_by!(code: "NG") do |country|
      country.name = "Nigeria"
      country.status = :active
      country.sort_order = 0
    end

    fct = nigeria.states.find_by(code: "FCT") ||
      nigeria.states.find_by("lower(name) IN (?)", [ "fct", "abuja-fct", "abuja fct", "federal capital territory" ])

    fct ||= nigeria.states.build(code: "FCT")
    fct.assign_attributes(name: "FCT", code: "FCT", status: :active)
    fct.save!

    CampDetail.where(state_name: [ "Abuja-FCT", "Abuja FCT", "Federal Capital Territory" ]).update_all(state_name: "FCT", state_id: fct.id)
    CampDetail.where(state_name: "FCT", state_id: nil).update_all(state_id: fct.id)
  end

  def down
    nigeria = Country.find_by(code: "NG")
    fct = nigeria&.states&.find_by(code: "FCT")
    return unless fct

    fct.update!(name: "Abuja-FCT")
    CampDetail.where(state_name: "FCT", state_id: fct.id).update_all(state_name: "Abuja-FCT")
  end
end
