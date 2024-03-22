class AddChecklistsAssignedToReviews < ActiveRecord::Migration[5.2]
  def up
    add_column    :reviews, :checklists_assigned, :boolean unless Review.column_names.include?('checklists_assigned')
  end

  def down
    remove_column :reviews, :checklists_assigned           if Review.column_names.include?('checklists_assigned')
  end
end
