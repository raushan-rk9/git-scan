class AddFullIdToRequirements < ActiveRecord::Migration[5.1]
  def up
     add_column :system_requirements,     :full_id, :text unless SystemRequirement.column_names.include?('full_id')
     add_column :high_level_requirements, :full_id, :text unless HighLevelRequirement.column_names.include?('full_id')
     add_column :low_level_requirements,  :full_id, :text unless LowLevelRequirement.column_names.include?('full_id')
     add_column :test_cases,              :full_id, :text unless TestCase.column_names.include?('full_id')
     add_column :source_codes,            :full_id, :text unless SourceCode.column_names.include?('full_id')

    add_index(:system_requirements,     [ :reqid,   :project_id ],           unique: true)                                                           unless index_exists?(:system_requirements,     [ :reqid,   :project_id ])
    add_index(:system_requirements,     [ :full_id, :project_id ],           unique: true)                                                           unless index_exists?(:system_requirements,     [ :full_id, :project_id ])
    add_index(:high_level_requirements, [ :reqid,   :project_id, :item_id ], unique: true, name: 'index_hlrs_on_reqid_and_project_id_and_item_id'  ) unless index_exists?(:high_level_requirements, [ :reqid,   :project_id, :item_id ], name: 'index_hlrs_on_reqid_and_project_id_and_item_id')
    add_index(:high_level_requirements, [ :full_id, :project_id, :item_id ], unique: true, name: 'index_hlrs_on_full_id_and_project_id_and_item_id') unless index_exists?(:high_level_requirements, [ :full_id, :project_id, :item_id ], name: 'index_hlrs_on_full_id_and_project_id_and_item_id')
    add_index(:low_level_requirements,  [ :reqid,   :project_id, :item_id ], unique: true, name: 'index_llrs_on_reqid_and_project_id_and_item_id'  ) unless index_exists?(:low_level_requirements,  [ :reqid,   :project_id, :item_id ], name: 'index_llrs_on_reqid_and_project_id_and_item_id')
    add_index(:low_level_requirements,  [ :full_id, :project_id, :item_id ], unique: true, name: 'index_llrs_on_full_id_and_project_id_and_item_id') unless index_exists?(:low_level_requirements,  [ :full_id, :project_id, :item_id ], name: 'index_llrs_on_full_id_and_project_id_and_item_id')
    add_index(:test_cases,              [ :caseid,  :project_id, :item_id ], unique: true)                                                           unless index_exists?(:test_cases,              [ :caseid,  :project_id, :item_id ])
    add_index(:test_cases,              [ :full_id, :project_id, :item_id ], unique: true)                                                           unless index_exists?(:test_cases,              [ :full_id, :project_id, :item_id ])
    add_index(:source_codes,            [ :codeid,  :project_id, :item_id ], unique: true)                                                           unless index_exists?(:source_codes,            [ :codeid,  :project_id, :item_id ])
    add_index(:source_codes,            [ :full_id, :project_id, :item_id ], unique: true)                                                           unless index_exists?(:source_codes,            [ :full_id, :project_id, :item_id ])
  end
end
