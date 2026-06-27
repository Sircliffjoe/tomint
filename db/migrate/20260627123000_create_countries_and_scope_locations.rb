class CreateCountriesAndScopeLocations < ActiveRecord::Migration[8.1]
  def up
    create_table :countries do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.text :description
      t.text :contact_info
      t.string :phone
      t.string :email
      t.text :address
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    add_index :countries, :code, unique: true
    add_index :countries, :slug, unique: true
    add_index :countries, [ :status, :sort_order, :name ]

    add_reference :states, :country, foreign_key: true
    add_reference :zones, :country, foreign_key: true

    nigeria = execute(<<~SQL.squish)
      INSERT INTO countries (name, code, slug, status, sort_order, created_at, updated_at)
      VALUES ('Nigeria', 'NG', 'nigeria', 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING id
    SQL

    nigeria_id = nigeria.first["id"]

    execute("UPDATE states SET country_id = #{nigeria_id} WHERE country_id IS NULL")
    execute("UPDATE zones SET country_id = #{nigeria_id} WHERE country_id IS NULL")

    change_column_null :states, :country_id, false
    change_column_null :zones, :country_id, false

    add_index :states, [ :country_id, :name ], unique: true
    add_index :states, [ :country_id, :code ], unique: true
    add_index :zones, [ :country_id, :name ], unique: true
  end

  def down
    remove_index :zones, [ :country_id, :name ]
    remove_index :states, [ :country_id, :code ]
    remove_index :states, [ :country_id, :name ]
    remove_reference :zones, :country, foreign_key: true
    remove_reference :states, :country, foreign_key: true
    drop_table :countries
  end
end
