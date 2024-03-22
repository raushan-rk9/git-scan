json.extract! project_access, :id, :user_id, :project_id, :access, :created_at, :updated_at
json.url project_access_url(project_access, format: :json)
