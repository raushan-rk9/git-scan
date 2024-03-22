class ChangeEnabledToDisabledInUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :user_enabled            if     User.column_names.include?('user_enabled')
    add_column    :users, :user_disabled, :boolean unless User.column_names.include?('user_disabled')
  end

  def down
    remove_column :users, :user_disabled           if     User.column_names.include?('user_disabled')
    add_column    :users, :user_enabled,  :boolean unless User.column_names.include?('user_enabled')
  end
end
