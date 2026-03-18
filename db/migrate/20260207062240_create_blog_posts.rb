class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.datetime :published_at
      t.belongs_to :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
