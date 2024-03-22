json.set! :data do
  json.array! @licensees do |licensee|
    json.partial! 'licensees/licensee', licensee: licensee
    json.url  "
              #{link_to 'Show', licensee }
              #{link_to 'Edit', edit_licensee_path(licensee)}
              #{link_to 'Destroy', licensee, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end