class AddSourceToTemplates < ActiveRecord::Migration[5.2]
  def up
    add_column    :templates,                :source, :string unless TemplateDocument.column_names.include?('source')
    add_column    :template_documents,       :source, :string unless TemplateDocument.column_names.include?('source')
    add_column    :template_checklists,      :source, :string unless TemplateChecklist.column_names.include?('source')
    add_column    :template_checklist_items, :source, :string unless TemplateChecklistItem.column_names.include?('source')

    execute "UPDATE templates                SET source='Airworthiness Certification Services';"
    execute "UPDATE template_documents       SET source='Airworthiness Certification Services';"
    execute "UPDATE template_checklists      SET source='Airworthiness Certification Services';"
    execute "UPDATE template_checklist_items SET source='Airworthiness Certification Services';"
  end

  def down
    remove_column :templates,                :source          if     TemplateDocument.column_names.include?('source')
    remove_column :template_documents,       :source          if     TemplateDocument.column_names.include?('source')
    remove_column :template_checklists,      :source          if     TemplateChecklist.column_names.include?('source')
    remove_column :template_checklist_items, :source          if     TemplateChecklistItem.column_names.include?('source')
  end
end
