class AddModelFileToRequirements < ActiveRecord::Migration[5.2]
  def change
    add_reference :system_requirements,     :model_file, foreign_key: true
    add_reference :high_level_requirements, :model_file, foreign_key: true
    add_reference :low_level_requirements,  :model_file, foreign_key: true
    add_reference :test_cases,              :model_file, foreign_key: true
  end
end
