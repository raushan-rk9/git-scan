class ChangeCodeCheckmarkIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :code_checkmarks,   :checkmark_id
    remove_index :code_checkmarks, [ :filename,
                                     :line_number
                                   ]
    add_index    :code_checkmarks, [
                                     :checkmark_id,
                                     :filename,
                                     :line_number
                                   ],
                 unique: true,
                 name: 'index_checkmarks_on_id_filename_and_line_number'
  end
end
