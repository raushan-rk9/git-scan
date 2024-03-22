class AddVersionToTemplates < ActiveRecord::Migration[5.2]
  def up
    add_column :templates,                :version, :string unless Template.column_names.include?('version')
    add_column :template_documents,       :version, :string unless TemplateDocument.column_names.include?('version')
    add_column :template_checklists,      :version, :string unless TemplateChecklist.column_names.include?('version')
    add_column :template_checklist_items, :version, :string unless TemplateChecklistItem.column_names.include?('version')
    add_column :checklist_items,          :version, :string unless ChecklistItem.column_names.include?('version')

    execute    "UPDATE templates                SET version='r1a';"
    execute    "UPDATE template_checklists      SET version='r1a';"
    execute    "UPDATE template_checklist_items SET version='r1a';"
    execute    "UPDATE checklist_items          SET version='r1a';"

    TemplateDocument.all.each do |document|
      filename = if document.file.attached?
                   document.file.filename
                 end

      if filename.present? && filename.to_s =~ /^.+\.(r[12])\..+$/
        execute "UPDATE template_documents SET version='#{$1}' WHERE id='#{document.id}';"
      else
        execute "UPDATE template_documents SET version='r1';"
      end
    end
  end

  def down
    remove_column :templates, :version                      if Template.column_names.include?('version')
    remove_column :template_documents,       :version       if TemplateDocument.column_names.include?('version')
    remove_column :template_checklists,      :version       if TemplateChecklist.column_names.include?('version')
    remove_column :template_checklist_items, :version       if TemplateChecklistItem.column_names.include?('version')
    remove_column :checklist_items,          :version       if ChecklistItem.column_names.include?('version')
  end
end
