class CreateDocumentAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :document_attachments do |t|
      t.references :document, foreign_key: true
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.string :user

      t.timestamps
    end
  end
end
