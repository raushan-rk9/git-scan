json.extract! review_attachment, :id, :review_id, :user, :item_id, :project_id, :created_at, :updated_at
json.url review_attachment_url(review_attachment, format: :json)
