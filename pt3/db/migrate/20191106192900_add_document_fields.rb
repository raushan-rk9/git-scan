class AddDocumentFields < ActiveRecord::Migration[5.1]
  def up
    add_reference    :documents, :review                  unless Document.column_names.include?('review_id')
    add_column       :documents, :document_type,  :string unless Document.column_names.include?('document_type')
    add_column       :documents, :review_status,  :string unless Document.column_names.include?('review_status')
    add_column       :documents, :draft_revision, :string unless Document.column_names.include?('draft_revision')
  end

  def down
    remove_reference :documents, :review                  if Document.column_names.include?('review_id')
    remove_column    :documents, :document_type           if Document.column_names.include?('document_type')
    remove_column    :documents, :review_status           if Document.column_names.include?('review_status')
    remove_column    :documents, :draft_revision          if Document.column_names.include?('draft_revision')
  end
end
