class AddPathAndParentToDocuments < ActiveRecord::Migration[5.2]
  def up
    add_reference    :documents, :parent,    belongs_to: :documents unless Document.column_names.include?('parent_id')
    add_column       :documents, :file_path, :string                unless Document.column_names.include?('file_path')
    add_column       :documents, :file_type, :string                unless Document.column_names.include?('file_type')
  end

  def down
    remove_reference :documents, :parent                            if Document.column_names.include?('parent_id')
    remove_column    :documents, :file_path                         if Document.column_names.include?('file_path')
    remove_column    :documents, :file_type                         if Document.column_names.include?('file_type')
  end
end
