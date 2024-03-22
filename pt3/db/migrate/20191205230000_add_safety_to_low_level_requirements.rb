class AddSafetyToLowLevelRequirements < ActiveRecord::Migration[5.2]
  def up
    add_column    :low_level_requirements, :safety, :boolean unless LowLevelRequirement.column_names.include?('safety')
  end

  def down
    remove_column :low_level_requirements, :safety           if LowLevelRequirement.column_names.include?('safety')
  end
end
