class CreateHighLevelRequirements < ActiveRecord::Migration[5.1]
  def change
    create_table :high_level_requirements do |t|
      t.integer :reqid, null: false
      t.text :full_id
      t.text :description
      t.text :category
      t.text :verification_method
      t.boolean :safety
      t.boolean :robustness
      t.boolean :derived
      t.string :testmethod
      t.integer :version
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.text :system_requirement_associations
      t.text :derived_justification

      t.timestamps
    end

    add_index :high_level_requirements, [ :reqid,   :project_id, :item_id ], unique: true, name: 'index_hlrs_on_reqid_and_project_id_and_item_id'
    add_index :high_level_requirements, [ :full_id, :project_id, :item_id ], unique: true, name: 'index_hlrs_on_full_id_and_project_id_and_item_id'
  end
end
