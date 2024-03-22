class CreateModelFiles < ActiveRecord::Migration[5.2]
  def change
    create_table   :model_files do |t|
      t.integer    :model_id
      t.string     :full_id
      t.text       :description
      t.string     :file_path
      t.string     :file_type
      t.string     :url_type
      t.string     :url_link
      t.string     :url_description
      t.boolean    :soft_delete
      t.boolean    :derived
      t.string     :derived_justification
      t.string     :system_requirement_associations
      t.string     :high_level_requirement_associations
      t.string     :low_level_requirement_associations
      t.string     :test_case_associations
      t.integer    :version
      t.string     :revision
      t.string     :draft_version
      t.date       :revision_date
      t.string     :organization

      t.references :project, foreign_key: true
      t.references :item,    foreign_key: true
      t.references :archive, foreign_key: true

      t.timestamps

      t.index [ :model_id, :project_id, :item_id, :archive_id ], unique: true, name: 'index_model_files_on_model_and_project_and_item_and_archive'
      t.index [ :full_id,  :project_id, :item_id, :archive_id ], unique: true, name: 'index_model_files_on_full_id_and_project_and_item_and_archive'
    end

    create_join_table :system_requirements, :model_files, table_name: 'sysreq_mfs' do |t|
      t.index [:system_requirement_id, :model_file_id]
      t.index [:model_file_id, :system_requirement_id]
    end

    create_join_table :high_level_requirements, :model_files, table_name: 'hlr_mfs' do |t|
      t.index [:high_level_requirement_id, :model_file_id]
      t.index [:model_file_id, :high_level_requirement_id]
    end

    create_join_table :low_level_requirements, :model_files, table_name: 'llr_mfs' do |t|
      t.index [:low_level_requirement_id, :model_file_id]
      t.index [:model_file_id, :low_level_requirement_id]
    end

    create_join_table :test_cases, :model_files, table_name: 'tc_mfs' do |t|
      t.index [:test_case_id, :model_file_id]
      t.index [:model_file_id, :test_case_id]
    end

    add_column :projects, :model_file_prefix, :string
    add_column :items, :model_file_prefix, :string
  end
end
