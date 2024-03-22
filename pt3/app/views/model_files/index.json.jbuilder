json.set! :data do
  json.array! @model_files do |model_file|
    json.partial! 'model_files/model_file', model_file: model_file
    json.url  "
              #{link_to 'Show', model_file }
              #{link_to 'Edit', edit_model_file_path(model_file)}
              #{link_to 'Destroy', model_file, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end