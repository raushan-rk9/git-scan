class CreateHlrTps < ActiveRecord::Migration[5.1]
  def change
    create_table :hlr_tps, id: false do |t|
      t.integer  :high_level_requirement_id
      t.integer  :test_procedure_id
    end

    add_index    :hlr_tps, :high_level_requirement_id
    add_index    :hlr_tps, :test_procedure_id
  end
end
