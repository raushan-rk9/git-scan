class CreateCodeCheckmarkHits < ActiveRecord::Migration[5.2]
  def change
    create_table   :code_checkmark_hits do |t|
      t.references :code_checkmark, foreign_key: true, null: false
      t.datetime   :hit_at,         limit:       6
      t.string     :organization

      t.timestamps
    end
  end
end
