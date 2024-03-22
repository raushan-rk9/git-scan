class AddIdPrefixToProjects < ActiveRecord::Migration[5.2]
  def up
    unless Project.column_names.include?('system_requirements_prefix')
      add_column :projects, :system_requirements_prefix, :string
      add_column :projects, :high_level_requirements_prefix, :string
      add_column :projects, :low_level_requirements_prefix, :string
      add_column :projects, :source_code_prefix, :string
      add_column :projects, :test_case_prefix, :string

      execute    "UPDATE projects SET system_requirements_prefix='SYS';"
      execute    "UPDATE projects SET high_level_requirements_prefix='HLR';"
      execute    "UPDATE projects SET low_level_requirements_prefix='LLR';"
      execute    "UPDATE projects SET source_code_prefix='SC';"
      execute    "UPDATE projects SET test_case_prefix='TC';"
    end
  end

  def down
    if Project.column_names.include?('system_requirements_prefix')
      remove_column :projects, :system_requirements_prefix
      remove_column :projects, :high_level_requirements_prefix
      remove_column :projects, :low_level_requirements_prefix
      remove_column :projects, :source_code_prefix
      remove_column :projects, :test_case_prefix
    end
  end
end
