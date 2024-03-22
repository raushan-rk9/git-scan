class AddCategoryVerificationMethodToRequirements < ActiveRecord::Migration[5.2]
  def up
    add_column :system_requirements,        :category,            :text unless SystemRequirement.column_names.include?('category')
    add_column :system_requirements,        :verification_method, :text unless SystemRequirement.column_names.include?('verification_method')
    add_column :high_level_requirements,    :category,            :text unless HighLevelRequirement.column_names.include?('category')
    add_column :high_level_requirements,    :verification_method, :text unless HighLevelRequirement.column_names.include?('verification_method')
    add_column :low_level_requirements,     :category,            :text unless LowLevelRequirement.column_names.include?('category')
    add_column :low_level_requirements,     :verification_method, :text unless LowLevelRequirement.column_names.include?('verification_method')
  end

  def down
    remove_column :system_requirements,     :category                   if SystemRequirement.column_names.include?('category')
    remove_column :system_requirements,     :verification_method        if SystemRequirement.column_names.include?('verification_method')
    remove_column :high_level_requirements, :category                   if HighLevelRequirement.column_names.include?('category')
    remove_column :high_level_requirements, :verification_method        if HighLevelRequirement.column_names.include?('verification_method')
    remove_column :low_level_requirements,  :category                   if LowLevelRequirement.column_names.include?('category')
    remove_column :low_level_requirements,  :verification_method        if LowLevelRequirement.column_names.include?('verification_method')
  end
end
