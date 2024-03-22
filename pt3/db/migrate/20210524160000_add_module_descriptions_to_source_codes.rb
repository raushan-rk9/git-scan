class AddModuleDescriptionsToSourceCodes < ActiveRecord::Migration[5.1]
  def change
    add_column :source_codes, :module_description_associations, :string unless SourceCode.column_names.include?('module_description_associations')

    create_table :md_scs, id: false do |t|
      t.integer :module_description_id
      t.integer :source_code_id
    end

    add_index  :md_scs, :module_description_id
    add_index  :md_scs, :source_code_id
  end
end
