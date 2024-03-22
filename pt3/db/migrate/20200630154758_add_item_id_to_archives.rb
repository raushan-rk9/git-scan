class AddItemIdToArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :archives, :item_id,    :integer
  end
end
