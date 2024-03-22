class AddParametersToTemplateDocuments < ActiveRecord::Migration[5.2]
  def up
    add_column    :template_documents, :docid,         :string unless TemplateDocument.column_names.include?('docid')
    add_column    :template_documents, :name,          :text   unless TemplateDocument.column_names.include?('name')
    add_column    :template_documents, :category,      :string unless TemplateDocument.column_names.include?('category')
    add_column    :template_documents, :document_type, :string unless TemplateDocument.column_names.include?('document_type')
    add_column    :template_documents, :file_type,     :string unless TemplateDocument.column_names.include?('file_type')
  end

  def down
    remove_column :template_documents, :docid                  if     TemplateDocument.column_names.include?('docid')
    remove_column :template_documents, :name                   if     TemplateDocument.column_names.include?('name')
    remove_column :template_documents, :category               if     TemplateDocument.column_names.include?('category')
    remove_column :template_documents, :document_type          if     TemplateDocument.column_names.include?('document_type')
    remove_column :template_documents, :file_type              if     TemplateDocument.column_names.include?('file_type')
  end
end
