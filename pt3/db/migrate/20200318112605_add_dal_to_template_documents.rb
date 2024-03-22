class AddDalToTemplateDocuments < ActiveRecord::Migration[5.2]
  def up
    add_column    :template_documents, :dal, :string unless TemplateDocument.column_names.include?('dal')
  end

  def down
    remove_column :template_documents, :dal          if     TemplateDocument.column_names.include?('dal')
  end
end
