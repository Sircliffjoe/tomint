class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages do |t|
      t.string :title
      t.string :slug

      t.timestamps
    end
    add_index :pages, :slug, unique: true
  end
end
