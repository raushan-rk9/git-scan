json.extract! action_item, :id, :actionitemid, :description, :openedby, :assignedto, :status, :note, :item_id, :project_id, :created_at, :updated_at
json.url action_item_url(action_item, format: :json)
