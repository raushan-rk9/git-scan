class AddModuleDescriptionToProjectAndItem < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :module_description_prefix, :text
    add_column :items,     :module_description_prefix, :text
  end
end
