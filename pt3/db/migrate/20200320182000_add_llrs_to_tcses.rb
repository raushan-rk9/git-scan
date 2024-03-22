class AddLlrsToTcses < ActiveRecord::Migration[5.1]
  def change
    create_table  :llr_tcs, id: false do |t|
      t.integer   :low_level_requirement_id
      t.integer   :test_case_id
    end

    create_table  :tcs_tps, id: false do |t|
      t.integer   :test_case_id
      t.integer   :test_procedure_id
    end

    remove_column :test_procedures, :low_level_requirement_associations,  :text if     TestProcedure.column_names.include?('low_level_requirement_associations')
    remove_column :test_procedures, :high_level_requirement_associations, :text if     TestProcedure.column_names.include?('high_level_requirement_associations')

    add_column    :test_cases,      :low_level_requirement_associations,  :text unless TestCase.column_names.include?('low_level_requirement_associations')
    add_column    :test_procedures, :test_case_associations,              :text unless TestProcedure.column_names.include?('test_case_associations')

    add_index     :llr_tcs,         :low_level_requirement_id
    add_index     :llr_tcs,         :test_case_id
    add_index     :tcs_tps,         :test_case_id
    add_index     :tcs_tps,         :test_procedure_id

    drop_table   :tps_tcs                                                       if     ActiveRecord::Base.connection.data_source_exists?('tps_tcs')
  end
end
