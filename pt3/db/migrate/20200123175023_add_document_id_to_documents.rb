class AddDocumentIdToDocuments < ActiveRecord::Migration[5.2]
  def up
    execute    "CREATE SEQUENCE documents_document_id_seq START 1"

    unless Document.column_names.include?('document_id')
      add_column :documents, :document_id, :integer
      add_index  :documents, :document_id
    end
  end

  def down
    execute "DROP SEQUENCE documents_document_id_seq"

    if Document.column_names.include?('document_id')
      remove_column :documents, :document_id
    end
  end
end
