class CreateHlrMds < ActiveRecord::Migration[5.2]
  def change
    create_table :hlr_mds, id: false do |t|
      t.integer :high_level_requirement_id
      t.integer :module_description_id
    end

    add_index :hlr_mds, :high_level_requirement_id
    add_index :hlr_mds, :module_description_id
  end
end
