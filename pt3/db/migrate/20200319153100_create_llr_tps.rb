class CreateLlrTps < ActiveRecord::Migration[5.1]
  def change
    create_table :llr_tps, id: false do |t|
      t.integer  :low_level_requirement_id
      t.integer  :test_procedure_id
    end

    add_index    :llr_tps, :low_level_requirement_id
    add_index    :llr_tps, :test_procedure_id
  end
end
