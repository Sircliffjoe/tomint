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

# States (Example)
states = [
  { name: "Lagos", code: "LAG", country: "Nigeria" },
  { name: "Abuja", code: "FCT", country: "Nigeria" },
  { name: "Rivers", code: "RIV", country: "Nigeria" }
]

states.each do |state_attrs|
  State.find_or_create_by!(code: state_attrs[:code]) do |state|
    state.name = state_attrs[:name]
    state.country = state_attrs[:country]
    state.status = :active
  end
end

puts "Created #{State.count} states."

# Super Admin User
admin_email = "admin@tomint.org"
User.find_or_create_by!(email: admin_email) do |user|
  user.first_name = "Super"
  user.last_name = "Admin"
  user.phone = "0000000000"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :super_admin
end

puts "Created super admin user: #{admin_email}"

# Report Categories
categories = [
  "Monthly Outreach Report",
  "Quarterly Financial Report",
  "Training Workshop Report",
  "Special Project Update",
  "State Visit Report"
]

categories.each do |cat_name|
  ReportCategory.find_or_create_by!(name: cat_name)
end

puts "Created #{ReportCategory.count} report categories."

# Events
Event.find_or_create_by!(title: "National Youth Conference 2026") do |event|
  event.start_time = DateTime.new(2026, 8, 15, 9, 0, 0)
  event.end_time = DateTime.new(2026, 8, 17, 17, 0, 0)
  event.location = "Camp Ground, Lagos-Ibadan Expressway"
  event.state = nil # National
  event.registration_open = true
  event.description = "<div><strong>Theme: The Rising Generation</strong><br>Join thousands of teenagers from across the nation for 3 days of intense worship, word, and workshops.</div>"
end

Event.find_or_create_by!(title: "Lagos State Workers Retreat") do |event|
  event.start_time = DateTime.new(2026, 3, 10, 8, 0, 0)
  event.end_time = DateTime.new(2026, 3, 10, 16, 0, 0)
  event.location = "Lagos State Secretariat"
  event.state = State.find_by(name: "Lagos")
  event.registration_open = true
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

BlogPost.create!(
  title: "Successfully Completed the National Youth Camp",
  body: "<div>We thank God for a successful camp meeting. Over 500 teenagers were in attendance, and many gave their lives to Christ. The atmosphere was charged with prayer and the word. We look forward to next year's edition with great anticipation.</div>",
  published_at: 1.week.ago,
  author: admin
)

BlogPost.create!(
  title: "New Training Center Opening Soon",
  body: "<div>We are excited to announce that our new training facility in Abuja will be opening next month. This center will serve as a hub for leadership development and discipleship training. Stay tuned for more details on the dedication ceremony.</div>",
  published_at: 2.days.ago,
  author: admin
)

puts "Created #{BlogPost.count} blog posts."
