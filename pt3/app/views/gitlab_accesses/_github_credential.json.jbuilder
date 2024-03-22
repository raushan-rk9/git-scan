json.extract! github_access, :id, :id, :username, :password, :token, :user_id, :created_at, :updated_at, :current_repository, :current_branch, :current_folder,
json.url github_access_url(github_access, format: :json)
