class AddModuleDescription < ActiveRecord::Migration[5.2]
  def change
    add_column :low_level_requirements, :module_description, :text
  end
end
