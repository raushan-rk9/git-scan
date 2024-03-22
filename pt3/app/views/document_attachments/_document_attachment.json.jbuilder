json.extract! document_attachment, :id, :document_id, :item_id, :project_id, :user, :created_at, :updated_at
json.url document_attachment_url(document_attachment, format: :json)
