class CreateItems < ActiveRecord::Migration[5.1]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :itemtype
      t.string :identifier
      t.string :level
      t.references :project, foreign_key: true

      # Use to keep counters for ID based models.
      # http://api.rubyonrails.org/classes/ActiveRecord/CounterCache/ClassMethods.html
      # https://stackoverflow.com/a/29440497
      t.integer :hlr_count, default: 0
      t.integer :llr_count, default: 0
      t.integer :review_count, default: 0
      t.integer :tc_count, default: 0
      t.integer :sc_count, default: 0

      t.timestamps
    end
  end
end
