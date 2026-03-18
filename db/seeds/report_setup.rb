# db/seeds/report_setup.rb

puts "Seeding Directorates and Report Categories..."

mappings = {
  "Administration" => [ "Annual Report" ],
  "Outreaches" => [ "Camp Report" ],
  "Training" => [ "Training Report" ],
  "Finance" => [ "Financial Report" ],
  "Prayer" => [ "Prayer Report" ],
  "Mobilization" => [ "Mobilization Report" ],
  "Media" => [ "Media Report" ],
  "Projects" => [ "Project Report" ]
}

mappings.each do |dir_name, categories|
  directorate = Directorate.find_or_create_by!(name: dir_name)
  puts "  Processed Directorate: #{directorate.name}"

  categories.each do |cat_name|
    category = ReportCategory.find_or_initialize_by(name: cat_name)
    category.directorate = directorate
    category.save!
    puts "    - Linked Category: #{category.name} -> #{directorate.name}"
  end
end

puts "Done!"
