class AddRepositoryUrlToGithubAccess < ActiveRecord::Migration[5.2]
  def up
    unless GithubAccess.column_names.include?('repository_url')
      add_column :github_accesses, :repository_url, :string
    end
  end

  def down
    if GithubAccess.column_names.include?('repository_url')
      remove_column :checklist_items, :status
    end
  end
end
