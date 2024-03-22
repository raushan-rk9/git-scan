json.set! :data do
  json.array! @module_descriptions do |module_description|
    json.partial! 'module_descriptions/module_description', module_description: module_description
    json.url  "
              #{link_to 'Show', module_description }
              #{link_to 'Edit', edit_module_description_path(module_description)}
              #{link_to 'Destroy', module_description, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end