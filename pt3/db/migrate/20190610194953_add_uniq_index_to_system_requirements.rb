class AddUniqIndexToSystemRequirements < ActiveRecord::Migration[5.2]
  def change
    add_index :system_requirements, [ :reqid,   :project_id ], unique: true unless index_exists?(:system_requirements, [ :reqid,   :project_id ])
    add_index :system_requirements, [ :full_id, :project_id ], unique: true unless index_exists?(:system_requirements, [ :full_id, :project_id ])
  end
end
