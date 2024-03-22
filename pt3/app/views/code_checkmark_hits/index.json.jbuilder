json.set! :data do
  json.array! @code_checkmark_hits do |code_checkmark_hit|
    json.partial! 'code_checkmark_hits/code_checkmark_hit', code_checkmark_hit: code_checkmark_hit
    json.url  "
              #{link_to 'Show', code_checkmark_hit }
              #{link_to 'Edit', edit_code_checkmark_hit_path(code_checkmark_hit)}
              #{link_to 'Destroy', code_checkmark_hit, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end