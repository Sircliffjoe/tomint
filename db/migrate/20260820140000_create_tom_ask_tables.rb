class CreateTomAskTables < ActiveRecord::Migration[8.1]
  def change
    create_table :ask_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon
      t.string :color, default: "emerald"
      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.integer :questions_count, default: 0, null: false

      t.timestamps
    end
    add_index :ask_categories, :slug, unique: true
    add_index :ask_categories, [ :active, :position ]

    create_table :ask_live_sessions do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :access_code, null: false
      t.text :description
      t.references :event, foreign_key: true, null: true
      t.integer :status, default: 0, null: false
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :anonymous_mode, default: true, null: false
      t.boolean :moderation_required, default: true, null: false
      t.boolean :voting_enabled, default: true, null: false
      t.integer :display_mode, default: 0, null: false
      t.bigint :current_question_id
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :questions_count, default: 0, null: false
      t.integer :participants_count, default: 0, null: false

      t.timestamps
    end
    add_index :ask_live_sessions, :slug, unique: true
    add_index :ask_live_sessions, :access_code, unique: true
    add_index :ask_live_sessions, :status

    create_table :ask_questions do |t|
      t.string :public_reference, null: false
      t.string :anonymous_identifier
      t.text :body, null: false
      t.text :anonymized_body
      t.references :ask_category, foreign_key: true, null: true
      t.references :ask_live_session, foreign_key: true, null: true
      t.integer :submission_type, default: 0, null: false
      t.integer :response_preference, default: 0, null: false
      t.integer :contact_method, default: 0, null: false
      t.string :contact_details
      t.integer :visibility, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.integer :priority, default: 1, null: false
      t.boolean :safeguarding_flag, default: false, null: false
      t.boolean :urgent_flag, default: false, null: false
      t.boolean :pinned, default: false, null: false
      t.boolean :featured, default: false, null: false
      t.integer :upvotes_count, default: 0, null: false
      t.integer :views_count, default: 0, null: false
      t.datetime :submitted_at, null: false
      t.datetime :reviewed_at
      t.datetime :answered_at
      t.datetime :closed_at
      t.text :moderation_reason
      t.string :ip_hash
      t.string :user_agent_hash

      t.timestamps
    end
    add_index :ask_questions, :public_reference, unique: true
    add_index :ask_questions, :status
    add_index :ask_questions, :visibility
    add_index :ask_questions, :safeguarding_flag
    add_index :ask_questions, :urgent_flag
    add_index :ask_questions, :pinned
    add_index :ask_questions, :featured
    add_index :ask_questions, :submission_type
    add_index :ask_questions, :submitted_at
    add_index :ask_questions, [ :ask_live_session_id, :status, :upvotes_count ], name: "idx_ask_questions_on_session_status_upvotes"

    create_table :ask_responses do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :response_type, default: 0, null: false
      t.integer :visibility, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.datetime :sent_at
      t.datetime :published_at

      t.timestamps
    end
    add_index :ask_responses, :status

    create_table :ask_assignments do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.references :assigned_by, null: false, foreign_key: { to_table: :users }
      t.datetime :assigned_at, null: false
      t.datetime :completed_at
      t.text :notes
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :ask_assignments, [ :ask_question_id, :active ]

    create_table :ask_internal_notes do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :safeguarding_only, default: false, null: false

      t.timestamps
    end

    create_table :ask_moderation_actions do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.text :details

      t.timestamps
    end

    create_table :ask_escalations do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.integer :escalation_type, default: 0, null: false
      t.integer :severity, default: 2, null: false
      t.text :reason, null: false
      t.references :assigned_safeguarding_lead, null: true, foreign_key: { to_table: :users }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.text :action_taken_notes
      t.datetime :resolved_at

      t.timestamps
    end
    add_index :ask_escalations, :status
    add_index :ask_escalations, :escalation_type

    create_table :ask_votes do |t|
      t.references :ask_question, null: false, foreign_key: true
      t.string :voter_token, null: false
      t.string :ip_hash

      t.timestamps
    end
    add_index :ask_votes, [ :ask_question_id, :voter_token ], unique: true
  end
end
