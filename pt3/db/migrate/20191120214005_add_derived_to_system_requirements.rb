class AddDerivedToSystemRequirements < ActiveRecord::Migration[5.2]
  def up
    add_column    :system_requirements, :derived, :boolean              unless SystemRequirement.column_names.include?('derived')
    add_column    :system_requirements, :derived_justification, :string unless SystemRequirement.column_names.include?('derived_justification')
  end

  def down
    remove_column :system_requirements, :derived                        if SystemRequirement.column_names.include?('derived')
    remove_column :system_requirements, :derived_justification          if SystemRequirement.column_names.include?('derived_justification')
  end
end
