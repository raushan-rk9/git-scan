class AddNotifyOnChangesToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column    :users, :notify_on_changes,       :boolean unless User.column_names.include?('notify_on_changes')
    add_column    :users, :user_enabled,            :boolean unless User.column_names.include?('user_enabled')
    add_column    :users, :password_reset_required, :boolean unless User.column_names.include?('password_reset_required')
  end

  def down
    remove_column :users, :notify_on_changes                 if User.column_names.include?('notify_on_changes')
    remove_column :users, :user_enabled                      if User.column_names.include?('user_enabled')
    remove_column :users, :password_reset_required           if User.column_names.include?('password_reset_required')
  end
end
