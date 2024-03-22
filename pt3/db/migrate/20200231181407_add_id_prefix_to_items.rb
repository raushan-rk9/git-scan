class AddIdPrefixToItems < ActiveRecord::Migration[5.2]
  def up
    unless Item.column_names.include?('system_requirements_prefix')
      add_column :items, :high_level_requirements_prefix, :string
      add_column :items, :low_level_requirements_prefix, :string
      add_column :items, :source_code_prefix, :string
      add_column :items, :test_case_prefix, :string

      execute    "UPDATE items SET high_level_requirements_prefix='HLR';"
      execute    "UPDATE items SET low_level_requirements_prefix='LLR';"
      execute    "UPDATE items SET source_code_prefix='SC';"
      execute    "UPDATE items SET test_case_prefix='TC';"
    end
  end

  def down
    if Item.column_names.include?('system_requirements_prefix')
      remove_column :items, :system_requirements_prefix
      remove_column :items, :high_level_requirements_prefix
      remove_column :items, :low_level_requirements_prefix
      remove_column :items, :source_code_prefix
      remove_column :items, :test_case_prefix
    end
  end
end
