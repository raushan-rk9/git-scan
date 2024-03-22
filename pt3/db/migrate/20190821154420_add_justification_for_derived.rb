class AddJustificationForDerived < ActiveRecord::Migration[5.2]
  def up
     add_column :high_level_requirements, :derived_justification, :text unless HighLevelRequirement.column_names.include?('derived_justification')
     add_column :low_level_requirements,  :derived_justification, :text unless LowLevelRequirement.column_names.include?('derived_justification')
     add_column :test_cases,              :derived_justification, :text unless TestCase.column_names.include?('derived_justification')
  end
end
