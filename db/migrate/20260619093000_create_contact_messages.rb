class CreateContactMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :subject, null: false
      t.text :message, null: false
      t.string :ip_address
      t.text :user_agent
      t.datetime :read_at

      t.timestamps
    end

    add_index :contact_messages, :created_at
    add_index :contact_messages, :read_at
  end
end
