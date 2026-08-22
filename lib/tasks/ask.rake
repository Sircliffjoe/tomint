# frozen_string_literal: true

namespace :ask do
  desc "Seed default TOM ASK categories without touching any other tables"
  task seed_categories: :environment do
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
      cat = AskCategory.find_or_initialize_by(slug: cat_data[:slug])
      cat.assign_attributes(
        name: cat_data[:name],
        color: cat_data[:color],
        position: cat_data[:position],
        description: cat_data[:description],
        active: true
      )
      cat.save!
    end

    puts "Successfully ensured #{AskCategory.count} TOM ASK categories."
  end
end
