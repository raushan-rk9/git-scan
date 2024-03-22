class AddAssignedAndUserIdToChecklists < ActiveRecord::Migration[5.2]
  def up
    add_column       :checklist_items, :assigned, :boolean unless ChecklistItem.column_names.include?('assigned')
    add_reference    :checklist_items, :user               unless ChecklistItem.column_names.include?('user_id')
  end

  def down
    remove_column    :checklist_items, :assigned           if ChecklistItem.column_names.include?('assigned')
    remove_reference :checklist_items, :user               if ChecklistItem.column_names.include?('user_id')
  end
end
