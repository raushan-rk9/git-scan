class CreateLowLevelRequirements < ActiveRecord::Migration[5.1]
  def change
    create_table :low_level_requirements do |t|
      t.integer :reqid
      t.text :full_id
      t.text :description
      t.text :category
      t.text :verification_method
      t.boolean :safety
      t.boolean :derived
      t.integer :version
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.text :high_level_requirement_associations
      t.text :derived_justification

      t.timestamps
    end

    add_index :low_level_requirements, [ :reqid,   :project_id, :item_id ], unique: true, name: 'index_llrs_on_reqid_and_project_id_and_item_id'
    add_index :low_level_requirements, [ :full_id, :project_id, :item_id ], unique: true, name: 'index_llrs_on_full_id_and_project_id_and_item_id'
  end
end
