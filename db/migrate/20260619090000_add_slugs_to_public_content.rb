require "set"

class AddSlugsToPublicContent < ActiveRecord::Migration[7.1]
  TABLES = %i[events trainings blog_posts].freeze

  def up
    TABLES.each do |table_name|
      add_column table_name, :slug, :string
    end

    TABLES.each do |table_name|
      backfill_slugs(table_name)
      add_index table_name, :slug, unique: true
      change_column_null table_name, :slug, false
    end
  end

  def down
    TABLES.each do |table_name|
      remove_index table_name, :slug
      remove_column table_name, :slug
    end
  end

  private

  def backfill_slugs(table_name)
    used_slugs = Set.new

    select_all("SELECT id, title FROM #{table_name} ORDER BY id").each do |record|
      base = record["title"].to_s.parameterize.presence || "#{table_name.to_s.singularize}-#{record["id"]}"
      candidate = base
      suffix = 2

      while used_slugs.include?(candidate)
        candidate = "#{base}-#{suffix}"
        suffix += 1
      end

      used_slugs.add(candidate)
      quoted_slug = connection.quote(candidate)
      execute("UPDATE #{table_name} SET slug = #{quoted_slug} WHERE id = #{record["id"].to_i}")
    end
  end
end
