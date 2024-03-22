class AddHlrsToLlrs < ActiveRecord::Migration[5.1]
  def change
    create_table :hlr_llrs, id: false do |t|
      t.integer :high_level_requirement_id
      t.integer :low_level_requirement_id
    end

    add_index :hlr_llrs, :high_level_requirement_id
    add_index :hlr_llrs, :low_level_requirement_id
  end
end
