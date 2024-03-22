class CreateDocumentComments < ActiveRecord::Migration[5.1]
  def change
    create_table :document_comments do |t|
      t.integer :commentid
      t.text :comment
      t.string :docrevision
      t.datetime :datemodified
      t.string :status
      t.string :requestedby
      t.string :assignedto
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.references :document, foreign_key: true

      t.timestamps
    end
  end
end
