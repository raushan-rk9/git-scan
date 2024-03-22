class AddCodeStatementToCodeCheckmarks < ActiveRecord::Migration[5.2]
  def up
    add_column    :code_checkmarks, :code_statement, :string unless CodeCheckmark.column_names.include?('code_statement')
  end

  def down
    remove_column :code_checkmarks, :code_statement           if CodeCheckmark.column_names.include?('code_statement')
  end
end
