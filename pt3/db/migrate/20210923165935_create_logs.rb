class CreateLogs < ActiveRecord::Migration[5.2]
  def up
    unless ActiveRecord::Base.connection.data_source_exists? 'logs'
      create_table :logs do |t|
        t.string   :log_category
        t.datetime :error_time
        t.text     :log_contents
        t.integer  :log_id
        t.text     :log_sha
        t.string   :log_type
        t.string   :log_contents
        t.text     :raw_line

        t.timestamps
      end
    end
  end

  def down
    if ActiveRecord::Base.connection.data_source_exists? 'logs'
      drop_table :logs
    end
  end
end