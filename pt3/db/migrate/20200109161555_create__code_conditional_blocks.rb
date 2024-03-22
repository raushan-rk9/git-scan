class CreateCodeConditionalBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table   :code_conditional_blocks do |t|
      t.references :source_code, foreign_key: true,          null: false
      t.string     :filename,                                null: false
      t.integer    :start_line_number,                       null: false
      t.integer    :end_line_number,                         null: false
      t.string     :condition
      t.boolean    :offset
      t.string     :organization

      t.timestamps
    end

    add_index    :code_conditional_blocks, [
                                             :source_code_id,
                                             :filename,
                                             :start_line_number,
                                             :end_line_number
                                           ],
                 unique: true,
                 name: 'index_blocks_on_source_code_filename_and_line_numbers'
  end
end
