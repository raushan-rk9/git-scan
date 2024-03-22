class CreateModuleDescriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :module_descriptions do |t|
      t.integer :module_description_number
      t.string :full_id
      t.text :description
      t.string :file_name
      t.integer :version
      t.string :revision
      t.string :draft_revision
      t.date :revision_date
      t.text :high_level_requirement_associations
      t.text :low_level_requirement_associations
      t.boolean :soft_delete
      t.integer :project_id
      t.integer :item_id
      t.integer :archive_id
      t.string :organization

      t.timestamps
    end
  end
end
