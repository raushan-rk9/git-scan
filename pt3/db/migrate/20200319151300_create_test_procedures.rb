class CreateTestProcedures < ActiveRecord::Migration[5.2]
  def change
    create_table   :test_procedures do |t|
      t.integer    :procedure_id
      t.text       :full_id
      t.text       :file_name
      t.text       :test_case_associations
      t.text       :url_type
      t.text       :url_description
      t.text       :url_link
      t.integer    :version
      t.string     :organization
      t.references :item,    foreign_key: true
      t.references :project, foreign_key: true
      t.references :archive, foreign_key: true

      t.timestamps
    end

    add_index :test_procedures, [ :procedure_id,  :project_id, :item_id ], unique: true, name: 'index_test_procedures_on_procedure_id_and_project_id_and_item'
    add_index :test_procedures, [ :full_id,       :project_id, :item_id ], unique: true
    add_index :test_procedures, :organization
  end
end
