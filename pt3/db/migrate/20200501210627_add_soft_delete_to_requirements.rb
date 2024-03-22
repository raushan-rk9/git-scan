class AddSoftDeleteToRequirements < ActiveRecord::Migration[5.2]
  def change
    add_column :high_level_requirements, :soft_delete, :boolean
    add_column :low_level_requirements,  :soft_delete, :boolean
    add_column :source_codes,            :soft_delete, :boolean
    add_column :system_requirements,     :soft_delete, :boolean
    add_column :test_cases,              :soft_delete, :boolean
    add_column :test_procedures,         :soft_delete, :boolean
  end
end
