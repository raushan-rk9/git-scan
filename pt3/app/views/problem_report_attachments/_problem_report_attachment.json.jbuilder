json.extract! problem_report_attachment, :id, :problem_report_id, :user, :item_id, :project_id, :created_at, :updated_at
json.url problem_report_attachment_url(problem_report_attachment, format: :json)
