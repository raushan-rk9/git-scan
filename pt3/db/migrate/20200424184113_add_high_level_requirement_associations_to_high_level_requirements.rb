class AddHighLevelRequirementAssociationsToHighLevelRequirements < ActiveRecord::Migration[5.2]
  def change
    create_table :hlr_hlrs, id: false do |t|
      t.integer :high_level_requirement_id
      t.integer :referenced_high_level_requirement_id
    end

    add_index :hlr_hlrs, :high_level_requirement_id
    add_index :hlr_hlrs, :referenced_high_level_requirement_id

    add_column :high_level_requirements, :high_level_requirement_associations, :string
  end
end
