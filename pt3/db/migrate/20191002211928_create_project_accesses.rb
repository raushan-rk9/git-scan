class CreateProjectAccesses < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :access, :string unless Project.column_names.include?('access')

    create_table :project_accesses do |t|
      t.belongs_to :user,    null: false, foreign_key: true
      t.belongs_to :project, null: false, foreign_key: true
      t.string     :access,  null: false

      t.timestamps
    end

    add_index  :project_accesses, [ :user_id, :project_id ], unique: true
  end
end
