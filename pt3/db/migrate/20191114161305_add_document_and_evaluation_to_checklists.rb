class AddDocumentAndEvaluationToChecklists < ActiveRecord::Migration[5.2]
  def up
    add_reference :checklist_items, :document                 unless ChecklistItem.column_names.include?('document_id')
    add_column    :checklist_items, :evaluator,       :string unless ChecklistItem.column_names.include?('evaluator')
    add_column    :checklist_items, :evaluation_date, :date   unless ChecklistItem.column_names.include?('evaluation_date')
  end

  def down
    remove_reference :checklist_items, :document              if ChecklistItem.column_names.include?('document_id')
    remove_column    :checklist_items, :evaluator             if ChecklistItem.column_names.include?('evaluator')
    remove_column    :checklist_items, :evaluation_date       if ChecklistItem.column_names.include?('evaluation_date')
  end
end
