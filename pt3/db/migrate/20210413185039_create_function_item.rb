class CreateFunctionItem < ActiveRecord::Migration[5.2]
  def change
    create_table :function_items do |t|
      t.integer  :function_item_id
      t.string   :full_id
      t.integer  :project_id
      t.integer  :item_id
      t.integer  :source_code_id
      t.string   :filename
      t.integer  :line_number
      t.string   :calling_function
      t.string   :calling_parameters
      t.integer  :called_by
      t.string   :function
      t.string   :function_parameters
      t.string   :organization
    end

    add_index :function_items, :project_id
    add_index :function_items, :item_id
    add_index :function_items, :called_by
    add_index :function_items, :full_id, unique: true
    add_index :function_items, [ :source_code_id, :filename, :line_number ], unique: true, name: 'index_function_items_on_source_code_id_filename_line_number'
  end
end
