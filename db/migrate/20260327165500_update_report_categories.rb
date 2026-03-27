class UpdateReportCategories < ActiveRecord::Migration[7.1]
  def up
    # Clear existing reports as requested
    Report.delete_all
    puts "Deleted all existing reports."

    # Core categories we want to keep
    core_categories = [
       "Annual Report",
       "Camp Report",
       "Training Report",
       "Financial Report"
    ]

    # Delete categories that are not in the core list
    ReportCategory.where.not(name: core_categories).delete_all
    puts "Deleted non-core report categories."

    # Ensure core categories exist
    core_categories.each do |name|
      ReportCategory.find_or_create_by!(name: name)
    end
    puts "Ensured core report categories exist: #{core_categories.join(', ')}"
  end

  def down
    # No easy way to restore deleted data, but we can leave the categories
  end
end
