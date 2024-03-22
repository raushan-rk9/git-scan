json.set! :data do
  json.array! @requirements_baselines do |requirements_baseline|
    json.partial! 'requirements_baselines/requirements_baseline', requirements_baseline: requirements_baseline
    json.url  "
              #{link_to 'Show', requirements_baseline }
              #{link_to 'Edit', edit_requirements_baseline_path(requirements_baseline)}
              #{link_to 'Destroy', requirements_baseline, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end