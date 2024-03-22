class AddTitleAndPhoneToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column    :users, :title, :text unless User.column_names.include?('title')
    add_column    :users, :phone, :text unless User.column_names.include?('phone')
  end

  def down
    remove_column :users, :title        if User.column_names.include?('title')
    remove_column :users, :phone        if User.column_names.include?('phone')
  end
end
