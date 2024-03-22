class CreateChecklistItems < ActiveRecord::Migration[5.1]
  def change
    create_table :checklist_items do |t|
      t.integer    :clitemid
      t.references :review,   foreign_key: true
      t.references :document, foreign_key: true
      t.text       :description
      t.text       :note
      t.string     :reference
      t.string     :minimumdal
      t.text       :supplements
      t.string     :status
      t.string     :evaluator
      t.date       :evaluation_date

      t.timestamps
    end
  end
end
