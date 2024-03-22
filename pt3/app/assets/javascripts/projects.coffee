# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Sort tables using tablesorter.
$(document).on "turbolinks:load", ->
  $('table').tablesorter()
  return
