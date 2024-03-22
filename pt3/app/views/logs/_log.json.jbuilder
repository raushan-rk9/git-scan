json.extract! log, :id, :error_time, :log_contents, log_type, :log_id, :log_sha, raw_line, :created_at, :updated_at
json.url log_url(log, format: :json)
