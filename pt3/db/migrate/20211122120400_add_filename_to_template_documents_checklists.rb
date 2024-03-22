class AddFilenameToTemplateDocumentsChecklists < ActiveRecord::Migration[5.2]
  def up
    unless TemplateDocument.column_names.include?('filename')
      add_column :template_documents, :filename, :string
    end
  end

  def down
    if TemplateDocument.column_names.include?('filename')
      remove_column :template_documents, :filename
    end
  end
end
