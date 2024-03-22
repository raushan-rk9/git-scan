json.extract! template_checklist_item, :id, clitemid, :title, :description, :passing, :failing, :status, :note, :checklist_id, :created_at, :updated_at
json.url template_checklist_item_url(template_checklist_item, format: :json)
