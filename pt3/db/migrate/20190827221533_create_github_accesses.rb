class CreateGithubAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :github_accesses do |t|
      t.text :username
      t.text :password
      t.text :token
      t.references :user, foreign_key: true
      t.text :last_accessed_repository
      t.text :last_accessed_branch
      t.text :last_accessed_folder
      t.text :last_accessed_file

      t.timestamps
    end
    add_index :github_accesses, :id
  end
end
