class CreateActionItems < ActiveRecord::Migration[5.1]
  def change
    create_table :action_items do |t|
      t.integer :actionitemid
      t.text :description
      t.string :openedby
      t.string :assignedto
      t.string :status
      t.text :note
      t.references :item, foreign_key: true
      t.references :project, foreign_key: true
      t.references :review, foreign_key: true

      t.timestamps
    end
  end
end
