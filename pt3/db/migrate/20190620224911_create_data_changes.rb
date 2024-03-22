class CreateDataChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :data_changes do |t|
      t.string   :changed_by,   null: false
      t.string   :table_name,   null: false
      t.integer  :table_id,     null: false
      t.string   :action,       null: false 
      t.datetime :performed_at, null: false
      t.json     :record_attributes
      t.boolean  :rolled_back

      t.timestamps
    end

    add_index :data_changes,
              [
                :changed_by,
                :table_name,
                :table_id,
                :action,
                :performed_at
              ],
              name: 'data_changes_unique_index',
              :unique => true
  end 
end
