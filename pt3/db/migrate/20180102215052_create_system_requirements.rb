class CreateSystemRequirements < ActiveRecord::Migration[5.1]
  def change
    create_table :system_requirements do |t|
      t.integer :reqid, null: false
      t.text :full_id
      t.text :description
      t.text :category
      t.text :verification_method
      t.string :source
      t.boolean :safety
      t.string :implementation
      t.integer :version
      t.boolean :derived
      t.text :derived_justification
      t.references :project, foreign_key: true

      t.timestamps
    end

    add_index :system_requirements, [ :reqid,   :project_id ], unique: true
    add_index :system_requirements, [ :full_id, :project_id ], unique: true
  end
end
