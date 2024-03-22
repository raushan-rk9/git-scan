class CreateSourceCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :source_codes do |t|
      t.integer :codeid
      t.text :full_id
      t.text :file_name
      t.text :module
      t.text :function
      t.boolean :derived
      t.text :derived_justification
      t.text :high_level_requirement_associations
      t.text :low_level_requirement_associations
      t.text :url_type
      t.text :url_description
      t.text :url_link
      t.integer :version
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end

    add_index :source_codes, [ :codeid,  :project_id, :item_id ], unique: true
    add_index :source_codes, [ :full_id, :project_id, :item_id ], unique: true
  end
end
