class CreateGitlabAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table   :gitlab_accesses do |t|
      t.text       :username
      t.text       :password
      t.text       :token
      t.references :user, foreign_key: true
      t.text       :last_accessed_repository
      t.text       :last_accessed_branch
      t.text       :last_accessed_folder
      t.text       :last_accessed_file
      t.string     :url
      t.string     :organization

      t.timestamps
    end
  
    add_index      :gitlab_accesses, :id
    add_index      :gitlab_accesses, :organization
  end
end
