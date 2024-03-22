class AddOmniauthToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :provider, :string unless User.column_names.include?('provider')
    add_column :users, :uid, :string      unless User.column_names.include?('uid')
  end

  def down
    remove_column :users, :provider       if User.column_names.include?('provider')
    remove_column :users, :uid            if User.column_names.include?('uid')
  end
end
