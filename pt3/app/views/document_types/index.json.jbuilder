json.set! :data do
  json.array! @document_types do |document_type|
    json.partial! 'document_types/document_type', document_type: document_type
    json.url  "
              #{link_to 'Show', document_type }
              #{link_to 'Edit', edit_document_type_path(document_type)}
              #{link_to 'Destroy', document_type, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end