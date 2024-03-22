class AddModelReferenceToSystemRequirements < ActiveRecord::Migration[5.2]
  def change
    add_reference :system_requirements,     :document, foreign_key: true
    add_reference :high_level_requirements, :document, foreign_key: true
    add_reference :low_level_requirements,  :document, foreign_key: true
    add_reference :test_cases,              :document, foreign_key: true
    add_reference :test_procedures,         :document, foreign_key: true
  end
end
