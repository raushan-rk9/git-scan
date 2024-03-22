class ChangeIndexes < ActiveRecord::Migration[5.1]
  def up
    execute 'DROP INDEX IF EXISTS index_system_requirements_on_reqid_and_project_id';
    execute 'DROP INDEX IF EXISTS index_system_requirements_on_full_id_and_project_id';
    execute 'DROP INDEX IF EXISTS index_hlrs_on_full_id_and_project_id_and_item_id';
    execute 'DROP INDEX IF EXISTS index_hlrs_on_reqid_and_project_id_and_item_id'
    execute 'DROP INDEX IF EXISTS index_llrs_on_reqid_and_project_id_and_item_id'
    execute 'DROP INDEX IF EXISTS index_llrs_on_full_id_and_project_id_and_item_id'
    execute 'DROP INDEX IF EXISTS index_test_cases_on_caseid_and_project_id_and_item_id'
    execute 'DROP INDEX IF EXISTS index_test_cases_on_full_id_and_project_id_and_item_id'

    add_index :system_requirements, [ :reqid,   :project_id, :archive_id ], unique: true, name: 'index_sysreq__on_reqid_and_project_id_and_archive_id'
    add_index :system_requirements, [ :full_id, :project_id, :archive_id ], unique: true, name: 'index_sysreq__on_fullid_and_project_id_and_archive_id'

    add_index :high_level_requirements, [ :reqid,   :project_id, :item_id, :archive_id ], unique: true, name: 'index_hlrs_on_reqid_and_project_id_and_item_id_and_archive_id'
    add_index :high_level_requirements, [ :full_id, :project_id, :item_id, :archive_id ], unique: true, name: 'index_hlrs_on_full_id_and_project_id_and_item_id_and_archive_id'

    add_index :low_level_requirements, [ :reqid,   :project_id, :item_id, :archive_id], unique: true, name: 'index_llrs_on_reqid_and_project_id_and_item_id_and_archive_id'
    add_index :low_level_requirements, [ :full_id, :project_id, :item_id, :archive_id], unique: true, name: 'index_llrs_on_full_id_and_project_id_and_item_id_and_archive_id'

    add_index :test_cases, [ :caseid,  :project_id, :item_id , :archive_id], unique: true, name: 'index_test_cases_caseid_project_id_item_id_archive_id'
    add_index :test_cases, [ :full_id, :project_id, :item_id , :archive_id], unique: true, name: 'index_test_cases_full_id_project_id_item_id_archive_id'
  end

  def down
    execute 'DROP INDEX index_sysreq__on_reqid_and_project_id_and_archive_id';
    execute 'DROP INDEX index_sysreq__on_fullid_and_project_id_and_archive_id';

    add_index :system_requirements, [ :reqid,   :project_id ], unique: true, name: 'index_sysreq__on_reqid_and_project_id_and_archive_id'
    add_index :system_requirements, [ :full_id, :project_id ], unique: true, name: 'index_sysreq__on_fullid_and_project_id_and_archive_id'
  end
end
