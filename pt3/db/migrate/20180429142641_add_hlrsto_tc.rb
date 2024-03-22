class AddHlrstoTc < ActiveRecord::Migration[5.1]
  def change
    create_table :hlr_tcs, id: false do |t|
      t.integer :high_level_requirement_id
      t.integer :test_case_id
    end

    add_index :hlr_tcs, :high_level_requirement_id
    add_index :hlr_tcs, :test_case_id
  end
end
