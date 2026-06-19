class CreateInternalMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :internal_messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :internal_messages, :created_at
    add_index :internal_messages, :read_at
  end
end
