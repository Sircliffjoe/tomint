class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :description
      t.boolean :priority, default: false

      t.timestamps
    end
  end
end
