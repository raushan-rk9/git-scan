json.extract! problem_report_history, :id, :action, :modifiedby, :status, :datemodified, :item_id, :project_id, :problem_report_id, :created_at, :updated_at
json.url problem_report_history_url(problem_report_history, format: :json)
