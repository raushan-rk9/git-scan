class AddChangeTypeToDataChanges < ActiveRecord::Migration[5.2]
  def up
    add_column    :data_changes, :change_type, :string             unless DataChange.column_names.include?('change_type')

    execute       "UPDATE data_changes SET change_type='UNDO';"
    execute       "UPDATE data_changes SET changed_by='gm_consulting@comcast.net' WHERE changed_by='Michelle Lange*'"
    execute       "UPDATE data_changes SET changed_by='paul@airworthinesscert.com' WHERE changed_by='Paul J. Carrick'"
    execute       "UPDATE data_changes SET changed_by='tammy@patmos-eng.com' WHERE changed_by='Tammy Reeve'"
    execute       "UPDATE data_changes SET changed_by='paulandvirginiacarrick@gmail.com' WHERE changed_by='Paul Jeffrey Carrick**'"
    execute       "UPDATE data_changes SET changed_by='admin@faaconsultants.com' WHERE changed_by='Admin User'"
    execute       "UPDATE data_changes SET changed_by='michelle@altech-marketing.com' WHERE changed_by='Michelle Lange'"
    execute       "UPDATE data_changes SET changed_by='scott.philiben@ciescorp.com' WHERE changed_by='Scott philiben'"
    execute       "UPDATE data_changes SET changed_by='rick.wright@ciescorp.com' WHERE changed_by='Rick Wright'"
    execute       "UPDATE data_changes SET changed_by='twhinfrey@oriondsi.com' WHERE changed_by='Thomas Whinfrey'"
    execute       "UPDATE data_changes SET changed_by='ryley.croghan@ciescorp.com' WHERE changed_by='Ryley Croghan'"
    execute       "UPDATE data_changes SET changed_by='dave@patmos-eng.com' WHERE changed_by='Dave Newton'"
    execute       "UPDATE data_changes SET changed_by='paul@patmos-eng.com' WHERE changed_by='Paul Carrick'"
    execute       "UPDATE data_changes SET changed_by='steve@patmos-eng.com' WHERE changed_by='Steve Gregor'"
    execute       "UPDATE data_changes SET changed_by='bdietz@ieeinc.com' WHERE changed_by='Brian Dietz'"

    remove_index :data_changes, name: 'data_changes_unique_index'  if     index_name_exists?(:data_changes,
                                                                                             :data_changes_unique_index)

    unless index_name_exists?(:data_changes, :data_changes_primary_index)
      add_index :data_changes,
                [
                  :changed_by,
                  :table_name,
                  :table_id,
                  :action,
                  :performed_at,
                  :change_type
                ],
                unique: true,
                name: 'data_changes_primary_index'
    end
  end

  def down
    remove_column :data_changes, :change_type                      if     DataChange.column_names.include?('change_type')

    remove_index :data_changes, name: 'data_changes_primary_index' if     index_name_exists?(:data_changes,
                                                                                             :data_changes_unique_index)

    unless index_name_exists?(:data_changes, :data_changes_unique_index)
      add_index :data_changes,
                  [
                    :changed_by,
                    :table_name,
                    :table_id,
                    :action,
                    :performed_at
                  ],
                  name: 'data_changes_unique_index',
                  unique: true
    end
  end
end
