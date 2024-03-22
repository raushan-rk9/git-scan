class CreateCodeCheckmarks < ActiveRecord::Migration[5.2]
  def change
    create_table   :code_checkmarks do |t|
      t.integer    :checkmark_id,                            null: false
      t.references :source_code, foreign_key: true,          null: false
      t.string     :filename,                                null: false
      t.integer    :line_number,                             null: false
      t.string     :code_statement
      t.string     :organization

      t.timestamps
    end

    add_index :code_checkmarks,   :checkmark_id,             unique: true
    add_index :code_checkmarks, [ :filename, :line_number ], unique: true
  end
end
