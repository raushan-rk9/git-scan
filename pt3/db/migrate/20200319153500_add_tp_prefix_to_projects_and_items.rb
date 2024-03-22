class AddTpPrefixToProjectsAndItems < ActiveRecord::Migration[5.2]
  def up
    add_column :projects,    :test_procedure_prefix, :string  unless Project.column_names.include?('test_procedure_prefix')
    add_column :items,       :test_procedure_prefix, :string  unless Item.column_names.include?('test_procedure_prefix')
    add_column :items,       :tp_count,               :integer unless Item.column_names.include?('tp_count')

    execute    "UPDATE projects SET test_procedure_prefix='TP';"
    execute    "UPDATE items    SET test_procedure_prefix='TP';"
  end

  def down
    remove_column :projects, :test_procedure_prefix       if         Project.column_names.include?('test_procedure_prefix')
    remove_column :items,    :test_procedure_prefix       if         Item.column_names.include?('test_procedure_prefix')
    remove_column :items,    :tp_count                     if         Item.column_names.include?('tp_count')
  end
end
