class SeedInternationalCampLocations < ActiveRecord::Migration[8.1]
  LOCATIONS = {
    "Ghana" => {
      code: "GH",
      sort_order: 10,
      states: [
        [ "Ahafo", "AHA" ],
        [ "Ashanti", "ASH" ],
        [ "Bono", "BON" ],
        [ "Bono East", "BEN" ],
        [ "Central", "CEN" ],
        [ "Eastern", "EAS" ],
        [ "Greater Accra", "GAR" ],
        [ "North East", "NER" ],
        [ "Northern", "NOR" ],
        [ "Oti", "OTI" ],
        [ "Savannah", "SAV" ],
        [ "Upper East", "UER" ],
        [ "Upper West", "UWR" ],
        [ "Volta", "VOL" ],
        [ "Western", "WES" ],
        [ "Western North", "WNR" ]
      ]
    },
    "United States" => {
      code: "US",
      sort_order: 20,
      states: [
        [ "Alabama", "AL" ],
        [ "Alaska", "AK" ],
        [ "Arizona", "AZ" ],
        [ "Arkansas", "AR" ],
        [ "California", "CA" ],
        [ "Colorado", "CO" ],
        [ "Connecticut", "CT" ],
        [ "Delaware", "DE" ],
        [ "District of Columbia", "DC" ],
        [ "Florida", "FL" ],
        [ "Georgia", "GA" ],
        [ "Hawaii", "HI" ],
        [ "Idaho", "ID" ],
        [ "Illinois", "IL" ],
        [ "Indiana", "IN" ],
        [ "Iowa", "IA" ],
        [ "Kansas", "KS" ],
        [ "Kentucky", "KY" ],
        [ "Louisiana", "LA" ],
        [ "Maine", "ME" ],
        [ "Maryland", "MD" ],
        [ "Massachusetts", "MA" ],
        [ "Michigan", "MI" ],
        [ "Minnesota", "MN" ],
        [ "Mississippi", "MS" ],
        [ "Missouri", "MO" ],
        [ "Montana", "MT" ],
        [ "Nebraska", "NE" ],
        [ "Nevada", "NV" ],
        [ "New Hampshire", "NH" ],
        [ "New Jersey", "NJ" ],
        [ "New Mexico", "NM" ],
        [ "New York", "NY" ],
        [ "North Carolina", "NC" ],
        [ "North Dakota", "ND" ],
        [ "Ohio", "OH" ],
        [ "Oklahoma", "OK" ],
        [ "Oregon", "OR" ],
        [ "Pennsylvania", "PA" ],
        [ "Rhode Island", "RI" ],
        [ "South Carolina", "SC" ],
        [ "South Dakota", "SD" ],
        [ "Tennessee", "TN" ],
        [ "Texas", "TX" ],
        [ "Utah", "UT" ],
        [ "Vermont", "VT" ],
        [ "Virginia", "VA" ],
        [ "Washington", "WA" ],
        [ "West Virginia", "WV" ],
        [ "Wisconsin", "WI" ],
        [ "Wyoming", "WY" ]
      ]
    },
    "United Kingdom" => {
      code: "UK",
      sort_order: 30,
      states: [
        [ "England", "ENG" ],
        [ "Northern Ireland", "NIR" ],
        [ "Scotland", "SCT" ],
        [ "Wales", "WLS" ]
      ]
    }
  }.freeze

  def up
    LOCATIONS.each do |country_name, config|
      country = Country.find_or_initialize_by(code: config[:code])
      country.assign_attributes(name: country_name, status: :active, sort_order: config[:sort_order])
      country.save!

      config[:states].each do |name, code|
        state = country.states.find_or_initialize_by(code: code)
        state.assign_attributes(name: name, status: :active, description: "TOM #{name} chapter.")
        state.save!
      end
    end
  end

  def down
    LOCATIONS.each do |country_name, config|
      country = Country.find_by(code: config[:code], name: country_name)
      next unless country

      config[:states].each do |name, code|
        state = country.states.find_by(code: code, name: name)
        state&.destroy! if state&.areas&.none? && state&.users&.none? && state&.reports&.none?
      end
    end
  end
end
