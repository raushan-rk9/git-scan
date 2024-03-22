# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  # On Page Load
  $('#export-form').hide()
  toggle_hide_state = false
  $('#hidden_type_input').parent().hide()

  # Functions
  # Toggle hide/show of element
  toggle_hide = (id) ->
    if toggle_hide_state is true
      $('#' + id).hide("fast")
      toggle_hide_state = false
    else
      $('#' + id).show("fast")
      toggle_hide_state = true

  # Button callbacks
  $('#show-user-link').click ->
    # show_form("export-form")
    toggle_hide("export-form")
    false
  $('#hide-user-link').click ->
    # hide_form("export-form")
    toggle_hide("export-form")
    false
  $('#export_type_input').change ->
    if $('#export_type_input').val() == '333'
      $('#hidden_type_input').fadeIn 'fast'
    return
  
  # Hide all other form fields on initial load.
  $('#item_input').parent().hide()
  # Get the states of the 
  states = $('#item_input').html()
  # When the project changes...
  $('#project_input').change ->
    # Get the selected project input value.
    project = $('#project_input :selected').text()
    # Get the relevant options for the defined project.
    options = $(states).filter("optgroup[label='#{project}']").html()
    if options
      # If there are options, prepend a blank option at the top of the list, and show it.
      $('#item_input').html(options).prepend("<option value='' selected='selected'></option>").parent().show("fast")
    else
      # Hide the list.
      $('#item_input').empty().parent().hide("fast")