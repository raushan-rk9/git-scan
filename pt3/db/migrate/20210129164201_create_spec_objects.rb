class CreateSpecObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :spec_objects do |t|
      t.string :type
      t.json   :value

      t.timestamps
    end
  end
end
