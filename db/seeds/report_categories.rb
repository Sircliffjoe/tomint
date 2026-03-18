
# Seed Standard Report Categories
categories = [
  "Camp report",
  "Annual State Report",
  "Quarterly State Reports",
  "Training Report",
  "Financial Report",
  "Media Report"
]

categories.each do |name|
  ReportCategory.find_or_create_by!(name: name)
end

puts "Seeded #{categories.count} report categories."
