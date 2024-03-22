class CreateTemplateChecklistItems < ActiveRecord::Migration[5.1]
  def change
    create_table :template_checklist_items do |t|
      t.integer    :clitemid
      t.text       :title
      t.text       :description
      t.text       :note
      t.references :template_checklist, foreign_key: true
      t.string     :reference
      t.string     :minimumdal
      t.text       :supplements
      t.string     :status

      t.timestamps
    end
  end
end
