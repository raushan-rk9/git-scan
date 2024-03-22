json.set! :data do
  json.array! @spec_objects do |spec_object|
    json.partial! 'spec_objects/spec_object', spec_object: spec_object
    json.url  "
              #{link_to 'Show', spec_object }
              #{link_to 'Edit', edit_spec_object_path(spec_object)}
              #{link_to 'Destroy', spec_object, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end