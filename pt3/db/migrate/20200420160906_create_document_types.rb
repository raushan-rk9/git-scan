class CreateDocumentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :document_types do |t|
      t.string :document_code
      t.string :description
      t.string :item_types
      t.string :dal_levels
      t.string :control_category
      t.string :organization

      t.timestamps
    end

    add_index :document_types, [ :document_code, :item_types, :dal_levels, :control_category], unique: true, name: 'index_document_types_on_type_item_types_dals_control_category'
    add_index :document_types, :organization
  end
end
