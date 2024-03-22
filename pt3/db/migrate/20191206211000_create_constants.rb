class CreateConstants < ActiveRecord::Migration[5.1]
  def change
    create_table :constants do |t|
      t.string :name
      t.string :label
      t.string :value

      t.timestamps
    end

    add_index :constants, [ :name, :label, :value], unique: true
  end
end
