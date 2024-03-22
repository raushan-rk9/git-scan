class AddArchiveTypeToArchives < ActiveRecord::Migration[5.2]
  def change_index(table, index_name, columns, direction)
    remove_index(table, name: index_name)                     if     index_name_exists?(table, index_name)
    columns.push(:archive_id)                                 if     direction == :up
    add_index(table, columns, unique: true, name: index_name) unless index_name_exists?(table, index_name)
  end

  def up
    add_column(:archives, :archive_type, :string) unless Archive.column_names.include?('archive_type')
    add_index(:archives, :archive_type)           unless index_name_exists?(:archives, :archive_type)

    change_index(:system_requirements,
                 'index_system_requirements_on_reqid_and_project_id',
                 [ :reqid, :project_id ],
                 :up)
    change_index(:system_requirements,
                 'index_system_requirements_on_full_id_and_project_id',
                 [ :full_id, :project_id ],
                 :up)
    change_index(:high_level_requirements,
                 'index_hlrs_on_reqid_and_project_id_and_item_id',
                 [ :reqid, :project_id, :item_id ],
                 :up)
    change_index(:high_level_requirements,
                 'index_hlrs_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :up)
    change_index(:low_level_requirements,
                 'index_llrs_on_reqid_and_project_id_and_item_id',
                 [ :reqid, :project_id, :item_id ],
                 :up)
    change_index(:low_level_requirements,
                 'index_llrs_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :up)
    change_index(:source_codes,
                 'index_source_codes_on_codeid_and_project_id_and_item_id',
                 [ :codeid,  :project_id, :item_id ],
                 :up)
    change_index(:source_codes,
                 'index_source_codes_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :up)
    change_index(:test_cases,
                 'index_test_cases_on_caseid_and_project_id_and_item_id',
                 [ :caseid,  :project_id, :item_id ],
                 :up)
    change_index(:test_cases,
                 'index_test_cases_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :up)
    change_index(:test_procedures,
                 'index_test_procedures_on_procedure_id_and_project_id_and_item',
                 [ :procedure_id,  :project_id, :item_id ],
                 :up)
    change_index(:test_procedures,
                 'index_test_procedures_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :up)
  end

  def down
    remove_column(:archives, :archive_type) if Archive.column_names.include?('archive_type')
    remove_index(:archives, :archive_type)  if index_name_exists?(:archives, :archive_type)

    change_index(:system_requirements,
                 'index_system_requirements_on_reqid_and_project_id',
                 [ :reqid, :project_id ],
                 :down)
    change_index(:system_requirements,
                 'index_system_requirements_on_full_id_and_project_id',
                 [ :full_id, :project_id ],
                 :down)
    change_index(:high_level_requirements,
                 'index_hlrs_on_reqid_and_project_id_and_item_id',
                 [ :reqid, :project_id, :item_id ],
                 :down)
    change_index(:high_level_requirements,
                 'index_hlrs_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :down)
    change_index(:low_level_requirements,
                 'index_llrs_on_reqid_and_project_id_and_item_id',
                 [ :reqid, :project_id, :item_id ],
                 :down)
    change_index(:low_level_requirements,
                 'index_llrs_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :down)
    change_index(:source_codes,
                 'index_source_codes_on_codeid_and_project_id_and_item_id',
                 [ :codeid,  :project_id, :item_id ],
                 :down)
    change_index(:source_codes,
                 'index_source_codes_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :down)
    change_index(:test_cases,
                 'index_test_cases_on_caseid_and_project_id_and_item_id',
                 [ :caseid,  :project_id, :item_id ],
                 :down)
    change_index(:test_cases,
                 'index_test_cases_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :down)
    change_index(:test_procedures,
                 'index_test_procedures_on_procedure_id_and_project_id_and_item',
                 [ :procedure_id,  :project_id, :item_id ],
                 :down)
    change_index(:test_procedures,
                 'index_test_procedures_on_full_id_and_project_id_and_item_id',
                 [ :full_id, :project_id, :item_id ],
                 :down)
  end
end
