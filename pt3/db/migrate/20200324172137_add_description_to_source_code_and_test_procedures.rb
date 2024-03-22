class AddDescriptionToSourceCodeAndTestProcedures < ActiveRecord::Migration[5.2]
  def change
    add_column :source_codes,    :description, :text
    add_column :test_procedures, :description, :text
  end
end
