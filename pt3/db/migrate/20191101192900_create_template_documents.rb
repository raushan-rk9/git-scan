class CreateTemplateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :template_documents do |t|
      t.integer    :document_id
      t.text       :title
      t.text       :description
      t.text       :notes
      t.string     :docid
      t.text       :name
      t.string     :category
      t.string     :document_type
      t.text       :document_class
      t.string     :file_type
      t.references :template, foreign_key: true
      t.string     :organization

      t.timestamps
    end
  end
end
