class ChangeChecklistItemPassFailToStatus < ActiveRecord::Migration[5.2]
  def up
    add_column :checklist_items, :status, :string unless ChecklistItem.column_names.include?('status')

    if ChecklistItem.column_names.include?('passing') &&
       ChecklistItem.column_names.include?('failing')
      checklist_items = ChecklistItem.all

      checklist_items.each do |checklist_item|
        if checklist_item.passing
          checklist_item.status = 'Pass'
        elseif checklist_item.failing
          checklist_item.status = 'Fail'
        end

        checklist_item.save!
      end

      remove_column :checklist_items, :passing
      remove_column :checklist_items, :failing
    end
  end

  def down
    add_column :checklist_items, :passing, :boolean unless ChecklistItem.column_names.include?('passing')
    add_column :checklist_items, :failing, :boolean unless ChecklistItem.column_names.include?('failing')

    if ChecklistItem.column_names.include?('status')
      checklist_items = ChecklistItem.all

      checklist_items.each do |checklist_item|
        if checklist_item.status == 'Pass'
          checklist_item.passing = true
        elseif checklist_item.status == 'Fail'
          checklist_item.failing = true
        end

        checklist_item.save!
      end

      remove_column :checklist_items, :status
    end
  end
end
