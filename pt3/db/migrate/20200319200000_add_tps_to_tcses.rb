class AddTpsToTcses < ActiveRecord::Migration[5.1]
  def change
    create_table :tps_tcs, id: false do |t|
      t.integer  :test_procedure_id
      t.integer  :test_case_id
    end

    add_column   :test_cases, :test_procedure_associations, :text unless TestCase.column_names.include?('test_procedure_associations')
    add_index    :tps_tcs,    :test_procedure_id
    add_index    :tps_tcs,    :test_case_id
  end
end
