class AddLlrsToScs < ActiveRecord::Migration[5.1]
  def change
    create_table :llr_scs, id: false do |t|
      t.integer :low_level_requirement_id
      t.integer :source_code_id
    end

    add_column :items,   :sc_count, :integer,        default: 0 unless Item.column_names.include?('sc_count')
    add_index  :llr_scs, :low_level_requirement_id
    add_index  :llr_scs, :source_code_id
  end
end
