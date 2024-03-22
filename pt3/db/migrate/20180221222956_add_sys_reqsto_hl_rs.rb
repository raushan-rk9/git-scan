class AddSysReqstoHlRs < ActiveRecord::Migration[5.1]
  def change
    create_table :sysreq_hlrs, id: false do |t|
      t.integer :system_requirement_id
      t.integer :high_level_requirement_id
    end

    add_index :sysreq_hlrs, :system_requirement_id
    add_index :sysreq_hlrs, :high_level_requirement_id
  end
end
