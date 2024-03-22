class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.integer :tlid
      t.text    :title
      t.text    :description
      t.text    :notes
      t.text    :template_class
      t.text    :template_type

      t.timestamps
    end
  end
end
