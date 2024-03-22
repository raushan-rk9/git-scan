json.extract! review, :id, :reviewid, :reviewtype, :title, :item_id, :project_id, :created_at, :updated_at
json.url review_url(review, format: :json)
