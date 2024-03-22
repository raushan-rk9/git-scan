class AddRefstoClitems < ActiveRecord::Migration[5.2]
  def change
    add_column :checklist_items, :reference,   :string unless ChecklistItem.column_names.include?('reference')
    add_column :checklist_items, :minimumdal,  :string unless ChecklistItem.column_names.include?('minimumdal')
    add_column :checklist_items, :supplements, :text   unless ChecklistItem.column_names.include?('supplements')
  end
end
