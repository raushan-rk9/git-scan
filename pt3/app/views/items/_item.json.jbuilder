json.extract! item, :id, :name, :itemtype, :description, :level, :project_id, :created_at, :updated_at
json.url item_url(item, format: :json)
