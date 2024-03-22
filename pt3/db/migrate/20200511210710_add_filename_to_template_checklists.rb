class AddFilenameToTemplateChecklists < ActiveRecord::Migration[5.2]
  def change
    add_column :template_checklists, :filename, :string
    add_column :template_checklists, :revision, :string
    add_column :template_checklists, :draft_revision, :string
    add_column :template_documents,  :revision, :string
    add_column :template_documents,  :draft_revision, :string
    add_column :document_comments,   :draft_revision, :string
  end
end
