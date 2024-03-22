class AddElementIdToArchives < ActiveRecord::Migration[5.2]
  def change
    add_column :archives, :element_id, :integer
  end
end
