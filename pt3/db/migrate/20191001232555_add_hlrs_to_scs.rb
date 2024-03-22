class AddHlrsToScs < ActiveRecord::Migration[5.1]
  def change
    add_column :source_codes, :high_level_requirement_associations, :string unless SourceCode.column_names.include?('high_level_requirement_associations')

    create_table :hlr_scs, id: false do |t|
      t.integer :high_level_requirement_id
      t.integer :source_code_id
    end

    add_index  :hlr_scs, :high_level_requirement_id
    add_index  :hlr_scs, :source_code_id
  end
end
