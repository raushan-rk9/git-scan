json.set! :data do
  json.array! @code_checkmarks do |code_checkmark|
    json.partial! 'code_checkmarks/code_checkmark', code_checkmark: code_checkmark
    json.url  "
              #{link_to 'Show', code_checkmark }
              #{link_to 'Edit', edit_code_checkmark_path(code_checkmark)}
              #{link_to 'Destroy', code_checkmark, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end