class CreateChangeSessions < ActiveRecord::Migration[5.2]
  def up 
    #create sequence for change_sessions table 

    execute <<-SQL__
      CREATE SEQUENCE session_id_seq 
        INCREMENT 1 
        MINVALUE  1 
     	  MAXVALUE  9223372036854775807 
        START     1 
      	CACHE     1; 
    SQL__

    create_table :change_sessions do |t|
      t.integer    :session_id, null: false
			t.references :data_change, foreign_key: true, null: false

      t.timestamps
    end

    add_index :change_sessions, :session_id
  end 

  def down 
    execute <<-DROP_SQL__
		  DROP SEQUENCE IF EXISTS session_id_seq;
		  DROP TABLE  IF EXISTS change_sessions;
    DROP_SQL__
  end 
end
