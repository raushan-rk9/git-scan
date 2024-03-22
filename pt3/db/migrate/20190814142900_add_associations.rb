class AddAssociations < ActiveRecord::Migration[5.2]
  def up
     add_column :high_level_requirements, :system_requirement_associations,     :text unless HighLevelRequirement.column_names.include?('system_requirement_associations')
     add_column :low_level_requirements,  :high_level_requirement_associations, :text unless LowLevelRequirement.column_names.include?('high_level_requirement_associations')
     add_column :test_cases,              :high_level_requirement_associations, :text unless TestCase.column_names.include?('high_level_requirement_associations')
  end
end
