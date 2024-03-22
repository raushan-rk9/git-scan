class CreateTestCases < ActiveRecord::Migration[5.1]
  def change
    create_table :test_cases do |t|
      t.integer :caseid
      t.text :full_id
      t.text :description
      t.text :procedure
      t.string :category
      t.boolean :robustness
      t.boolean :derived
      t.string :testmethod
      t.integer :version
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.text :high_level_requirement_associations
      t.text :low_level_requirement_associations
      t.text :derived_justification

      t.timestamps
    end

    add_index :test_cases, [ :caseid,  :project_id, :item_id ], unique: true
    add_index :test_cases, [ :full_id, :project_id, :item_id ], unique: true
  end
end
