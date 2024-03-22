class AddIdsToArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :archives, :archive_project_id, :integer
    add_column :archives, :archive_item_id,    :integer
    add_column :archives, :archive_item_ids,   :string
  end
end
