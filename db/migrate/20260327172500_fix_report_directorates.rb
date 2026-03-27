class FixReportDirectorates < ActiveRecord::Migration[7.1]
  def up
    # 1. Ensure directorates exist (names from seeds)
    admin = Directorate.find_or_create_by!(name: "Administration")
    outreach = Directorate.find_or_create_by!(name: "Outreaches")
    training = Directorate.find_or_create_by!(name: "Training")
    finance = Directorate.find_or_create_by!(name: "Finance")

    # 2. Map Core Categories to Directorates
    mappings = {
      "Annual Report" => admin,
      "Camp Report" => outreach,
      "Training Report" => training,
      "Financial Report" => finance
    }

    mappings.each do |cat_name, directorate|
      cat = ReportCategory.find_or_create_by!(name: cat_name)
      cat.update!(directorate: directorate)
    end

    puts "Mapped 4 core categories to their respective directorates."
  end

  def down
    # Optional: remove associations, but likely not needed for rollback
  end
end
