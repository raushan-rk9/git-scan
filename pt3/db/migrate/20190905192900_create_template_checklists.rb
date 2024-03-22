class CreateTemplateChecklists < ActiveRecord::Migration[5.1]
  def change
    create_table :template_checklists do |t|
      t.integer    :clid
      t.text       :title
      t.text       :description
      t.text       :notes
      t.text       :checklist_class
      t.text       :checklist_type
      t.references :template, foreign_key: true

      t.timestamps
    end
  end
end
