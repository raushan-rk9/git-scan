json.set! :data do
  json.array! @logs do |log|
    json.partial! 'logs/log', log: log
    json.url  "
              #{link_to 'Show', log }
              #{link_to 'Edit', edit_log_path(log)}
              #{link_to 'Destroy', log, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end