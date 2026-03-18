# db/seeds/migrate_categories.rb

# defined mappings: old_name => new_name
migrations = {
  "Camp report" => "Camp Report",
  "Annual State Report" => "Annual Report",
  "Quarterly Financial Report" => "Financial Report",
  "Training Workshop Report" => "Training Report",
  "Special Project Update" => "Project Report"
}

migrations.each do |old_name, new_name|
  old_cat = ReportCategory.find_by(name: old_name)
  new_cat = ReportCategory.find_by(name: new_name)

  if old_cat && new_cat
    count = old_cat.reports.update_all(report_category_id: new_cat.id)
    puts "Moved #{count} reports from '#{old_name}' to '#{new_name}'"
    old_cat.destroy
    puts "Deleted legacy category '#{old_name}'"
  elsif old_cat && !new_cat
     puts "Warning: New category '#{new_name}' not found. Skipping migration for '#{old_name}'"
  end
end

puts "Cleanup complete."
