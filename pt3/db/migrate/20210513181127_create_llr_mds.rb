class CreateLlrMds < ActiveRecord::Migration[5.2]
  def change
    create_table :llr_mds, id: false do |t|
      t.integer :low_level_requirement_id
      t.integer :module_description_id
    end

    add_index :llr_mds, :low_level_requirement_id
    add_index :llr_mds, :module_description_id
  end
end
