class AddOrganizationToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column    :users, :organization, :text unless User.column_names.include?('organization')
  end

  def down
    remove_column :users, :organization        if User.column_names.include?('organization')
  end
end
