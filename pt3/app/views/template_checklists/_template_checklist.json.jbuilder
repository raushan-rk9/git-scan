json.extract! template_checklist, :id, :clid, :title, :description, :checklist_type, :checklist_class, :notes, :template_id, :created_at, :updated_at
json.url checklist_item_url(template_checklist, format: :json)
