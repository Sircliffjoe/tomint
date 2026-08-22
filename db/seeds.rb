# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Directorates
directorate_names = [
  "Outreaches",
  "Administration",
  "Prayer",
  "Mobilization",
  "Training",
  "Media",
  "Finance",
  "Projects"
]

directorate_names.each do |name|
  Directorate.find_or_create_by!(name: name)
end

puts "Created #{Directorate.count} directorates."

# Zones
zones_data = [
  { name: "East", description: "Eastern zone of TOM covering the South-East states of Nigeria." },
  { name: "North", description: "Northern zone of TOM covering the Northern states and FCT." },
  { name: "West", description: "Western zone of TOM covering the South-West states of Nigeria." },
  { name: "South-South", description: "South-South zone of TOM covering the Niger Delta states." }
]

zones_data.each do |z|
  Zone.find_or_create_by!(name: z[:name]) do |zone|
    zone.description = z[:description]
  end
end

puts "Created #{Zone.count} zones."

# States
states_data = {
  "East" => [
    { name: "Abia", code: "ABI", year_created: 2020 },
    { name: "Anambra", code: "ANA", year_created: 2013 },
    { name: "Ebonyi", code: "EBO", year_created: 2016 },
    { name: "Enugu", code: "ENU", year_created: 2017 },
    { name: "Imo", code: "IMO", year_created: 1999 }
  ],
  "North" => [
    { name: "FCT", code: "FCT", year_created: 1996 },
    { name: "Adamawa", code: "ADA", year_created: 2010 },
    { name: "Bauchi", code: "BAU", year_created: 2020 },
    { name: "Benue", code: "BEN", year_created: 1994 },
    { name: "Borno", code: "BOR", year_created: 2014 },
    { name: "Kaduna", code: "KAD", year_created: 2001 },
    { name: "Kebbi", code: "KEB", year_created: 2006 },
    { name: "Kogi", code: "KOG", year_created: 2001 },
    { name: "Plateau", code: "PLA", year_created: 1996 },
    { name: "Taraba", code: "TAR", year_created: 2015 },
    { name: "Zamfara", code: "ZAM", year_created: 2022 }
  ],
  "West" => [
    { name: "Ekiti", code: "EKI", year_created: nil },
    { name: "Kwara", code: "KWA", year_created: 1992 },
    { name: "Lagos", code: "LAG", year_created: 1998 },
    { name: "Ogun", code: "OGU", year_created: 2023 },
    { name: "Osun", code: "OSU", year_created: 2003 },
    { name: "Oyo", code: "OYO", year_created: 1996 }
  ],
  "South-South" => [
    { name: "Akwa Ibom", code: "AKI", year_created: 2012 },
    { name: "Cross River", code: "CRS", year_created: 1995 },
    { name: "Delta", code: "DEL", year_created: 1993 },
    { name: "Edo", code: "EDO", year_created: 2022 },
    { name: "Rivers", code: "RIV", year_created: 1994 }
  ]
}

states_data.each do |zone_name, states|
  zone = Zone.find_by!(name: zone_name)
  states.each do |s|
    state = State.find_by(code: s[:code]) || State.find_by(name: s[:name]) || State.new
    state.assign_attributes(
      name: s[:name],
      code: s[:code],
      country: "Nigeria",
      status: :active,
      zone: zone,
      year_created: s[:year_created],
      description: s[:year_created] ? "TOM #{s[:name]} State, established in #{s[:year_created]}." : "TOM #{s[:name]} State."
    )
    state.save!
  end
end

puts "Created #{State.count} states."

international_locations = {
  "Ghana" => {
    code: "GH",
    sort_order: 10,
    states: [
      [ "Ahafo", "AHA" ],
      [ "Ashanti", "ASH" ],
      [ "Bono", "BON" ],
      [ "Bono East", "BEN" ],
      [ "Central", "CEN" ],
      [ "Eastern", "EAS" ],
      [ "Greater Accra", "GAR" ],
      [ "North East", "NER" ],
      [ "Northern", "NOR" ],
      [ "Oti", "OTI" ],
      [ "Savannah", "SAV" ],
      [ "Upper East", "UER" ],
      [ "Upper West", "UWR" ],
      [ "Volta", "VOL" ],
      [ "Western", "WES" ],
      [ "Western North", "WNR" ]
    ]
  },
  "United States" => {
    code: "US",
    sort_order: 20,
    states: [
      [ "Alabama", "AL" ],
      [ "Alaska", "AK" ],
      [ "Arizona", "AZ" ],
      [ "Arkansas", "AR" ],
      [ "California", "CA" ],
      [ "Colorado", "CO" ],
      [ "Connecticut", "CT" ],
      [ "Delaware", "DE" ],
      [ "District of Columbia", "DC" ],
      [ "Florida", "FL" ],
      [ "Georgia", "GA" ],
      [ "Hawaii", "HI" ],
      [ "Idaho", "ID" ],
      [ "Illinois", "IL" ],
      [ "Indiana", "IN" ],
      [ "Iowa", "IA" ],
      [ "Kansas", "KS" ],
      [ "Kentucky", "KY" ],
      [ "Louisiana", "LA" ],
      [ "Maine", "ME" ],
      [ "Maryland", "MD" ],
      [ "Massachusetts", "MA" ],
      [ "Michigan", "MI" ],
      [ "Minnesota", "MN" ],
      [ "Mississippi", "MS" ],
      [ "Missouri", "MO" ],
      [ "Montana", "MT" ],
      [ "Nebraska", "NE" ],
      [ "Nevada", "NV" ],
      [ "New Hampshire", "NH" ],
      [ "New Jersey", "NJ" ],
      [ "New Mexico", "NM" ],
      [ "New York", "NY" ],
      [ "North Carolina", "NC" ],
      [ "North Dakota", "ND" ],
      [ "Ohio", "OH" ],
      [ "Oklahoma", "OK" ],
      [ "Oregon", "OR" ],
      [ "Pennsylvania", "PA" ],
      [ "Rhode Island", "RI" ],
      [ "South Carolina", "SC" ],
      [ "South Dakota", "SD" ],
      [ "Tennessee", "TN" ],
      [ "Texas", "TX" ],
      [ "Utah", "UT" ],
      [ "Vermont", "VT" ],
      [ "Virginia", "VA" ],
      [ "Washington", "WA" ],
      [ "West Virginia", "WV" ],
      [ "Wisconsin", "WI" ],
      [ "Wyoming", "WY" ]
    ]
  },
  "United Kingdom" => {
    code: "UK",
    sort_order: 30,
    states: [
      [ "England", "ENG" ],
      [ "Northern Ireland", "NIR" ],
      [ "Scotland", "SCT" ],
      [ "Wales", "WLS" ]
    ]
  }
}

international_locations.each do |country_name, config|
  country = Country.find_or_initialize_by(code: config[:code])
  country.assign_attributes(name: country_name, status: :active, sort_order: config[:sort_order])
  country.save!

  config[:states].each do |state_name, code|
    state = country.states.find_or_initialize_by(code: code)
    state.assign_attributes(
      name: state_name,
      status: :active,
      description: "TOM #{state_name} chapter."
    )
    state.save!
  end
end

puts "Created #{Country.count} countries and #{State.count} total states/regions."

# Super Admin User
admin_email = "tommediang@gmail.com"
User.find_or_create_by!(email: admin_email) do |user|
  user.first_name = "Super"
  user.last_name = "Admin"
  user.phone = "+234 803 086 9716"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :super_admin
end

puts "Created super admin user: #{admin_email}"

# Report Categories
# Clear existing reports and non-core categories as requested
Report.delete_all
# Sync core categories with directorates
mappings = {
  "Annual Report" => "Administration",
  "Camp Report" => "Outreaches",
  "Training Report" => "Training",
  "Financial Report" => "Finance"
}

mappings.each do |cat_name, dir_name|
  dir = Directorate.find_by(name: dir_name)
  cat = ReportCategory.find_or_create_by!(name: cat_name)
  cat.update!(directorate: dir) if dir
end

puts "Synced #{ReportCategory.count} report categories with directorates."

# Events
Event.find_or_create_by!(title: "National Youth Conference 2026") do |event|
  event.start_time = DateTime.new(2026, 8, 15, 9, 0, 0)
  event.end_time = DateTime.new(2026, 8, 17, 17, 0, 0)
  event.location = "Camp Ground, Lagos-Ibadan Expressway"
  event.state = nil # National
  event.description = "<div><strong>Theme: The Rising Generation</strong><br>Join thousands of teenagers from across the nation for 3 days of intense worship, word, and workshops.</div>"
end

Event.find_or_create_by!(title: "Lagos State Workers Retreat") do |event|
  event.start_time = DateTime.new(2026, 3, 10, 8, 0, 0)
  event.end_time = DateTime.new(2026, 3, 10, 16, 0, 0)
  event.location = "Lagos State Secretariat"
  event.state = State.find_by(name: "Lagos")
  event.description = "<div>Annual retreat for all TOM workers in Lagos State. A time of refreshing and strategic planning.</div>"
end

puts "Created #{Event.count} events."

# Trainings
training = Training.find_or_create_by!(title: "Foundations of Leadership") do |t|
  t.category = "Leadership"
  t.description = "<div>A comprehensive course for new leaders in the ministry. Covers the basics of servant leadership, integrity, and vision.</div>"
end

TrainingSession.find_or_create_by!(title: "The Heart of a Servant", training: training) do |s|
  s.media_url = "https://www.youtube.com/embed/dQw4w9WgXcQ" # Placeholder
  s.duration = 45
end

TrainingSession.find_or_create_by!(title: "Vision and Strategy", training: training) do |s|
  s.media_url = "https://www.youtube.com/embed/dQw4w9WgXcQ" # Placeholder
  s.duration = 60
end

training2 = Training.find_or_create_by!(title: "Effective Evangelism") do |t|
  t.category = "Outreach"
  t.description = "<div>Learn how to share the gospel effectively with teenagers in today's culture.</div>"
end

TrainingSession.find_or_create_by!(title: "Understanding Gen Z", training: training2) do |s|
  s.media_url = "https://www.youtube.com/embed/dQw4w9WgXcQ" # Placeholder
  s.duration = 50
end

puts "Created #{Training.count} trainings and sessions."

# Blog Posts
admin = User.find_by(email: "admin@tomint.org")

BlogPost.find_or_create_by!(title: "Successfully Completed the National Youth Camp") do |post|
  post.body = "<div>We thank God for a successful camp meeting. Over 500 teenagers were in attendance, and many gave their lives to Christ. The atmosphere was charged with prayer and the word. We look forward to next year's edition with great anticipation.</div>"
  post.published_at = 1.week.ago
  post.author = admin
end

BlogPost.find_or_create_by!(title: "New Training Center Opening Soon") do |post|
  post.body = "<div>We are excited to announce that our new training facility in Abuja will be opening next month. This center will serve as a hub for leadership development and discipleship training. Stay tuned for more details on the dedication ceremony.</div>"
  post.published_at = 2.days.ago
  post.author = admin
end

puts "Created #{BlogPost.count} blog posts."

# ==========================================
# TOM ASK SEED DATA (Categories & Settings)
# ==========================================
puts "Seeding TOM ASK categories..."

ask_categories_data = [
  { name: "Faith & God", slug: "faith-god", color: "emerald", position: 1, description: "Questions about God, the Bible, faith, prayer, and spiritual doubts." },
  { name: "Family", slug: "family", color: "blue", position: 2, description: "Navigating family relationships, parents, siblings, and home life." },
  { name: "Friendship", slug: "friendship", color: "purple", position: 3, description: "Making true friends, handling betrayal, loneliness, and social dynamics." },
  { name: "School & Academics", slug: "school-academics", color: "amber", position: 4, description: "Exam stress, career choices, teachers, and school pressure." },
  { name: "Relationships & Dating", slug: "relationships-dating", color: "rose", position: 5, description: "Feelings, crushes, boundaries, purity, and relationship questions." },
  { name: "Body & Growing Up", slug: "body-growing-up", color: "orange", position: 6, description: "Changes during puberty, physical appearance, and self-image." },
  { name: "Emotions & Mental Well-being", slug: "emotions", color: "blue", position: 7, description: "Dealing with anxiety, sadness, anger, fear, and emotional struggles." },
  { name: "Peer Pressure", slug: "peer-pressure", color: "purple", position: 8, description: "Standing strong against negative habits, trends, and pressure to fit in." },
  { name: "Identity & Purpose", slug: "identity-purpose", color: "emerald", position: 9, description: "Discovering who you are, God's calling, talents, and future." },
  { name: "Something Happened", slug: "something-happened", color: "rose", position: 10, description: "Personal incidents, sensitive concerns, or sharing what happened to you." },
  { name: "Something Else", slug: "something-else", color: "gray", position: 11, description: "Any other question or concern not covered in the above topics." }
]

ask_categories_data.each do |cat_data|
  AskCategory.find_or_create_by!(slug: cat_data[:slug]) do |cat|
    cat.name = cat_data[:name]
    cat.color = cat_data[:color]
    cat.position = cat_data[:position]
    cat.description = cat_data[:description]
    cat.active = true
  end
end

puts "Created #{AskCategory.count} TOM ASK categories."

