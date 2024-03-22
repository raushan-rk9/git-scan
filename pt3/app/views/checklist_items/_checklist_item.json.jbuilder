json.extract! checklist_item, :id, :clitemid, :description, :passing, :failing, :status, :note, :item_id, :project_id, :checklist_id, :created_at, :updated_at
json.url checklist_item_url(checklist_item, format: :json)
