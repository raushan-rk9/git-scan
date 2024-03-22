var formDirty = false;

function validateForm()
{
  var result      = true;
  var firstError  = null;

  // Clear Previous Errors
  $('*[data-validate=true]').each(function() {
    if ($(this).attr('required') == 'required')
    {
      var label   = $("label[for='" + $(this).attr('id') + "']");
      var text    = label.text();

      text.replace(' <b style="color:red;">Needs to be filled in</b>', '');
      label.text(text);
      $(this).removeClass('field_with_errors');
    }
  });

  // Check to see that required fields are filled in
  $('*[data-validate=true]').each(function() {
    if ($(this).attr('required') == 'required')
    {
      if ($(this).val() === "")
      {
        if (firstError == null)
          firstError = $(this);

        $("label[for='" + $(this).attr('id') + "']").append(' <b style="color:red;">Needs to be filled in</b>');
        $(this).addClass('field_with_errors');

        result    = false;
      }
    }
  });

  if (firstError != null)
    $(firstError).focus();

  return(result);
}

function file_validation(fieldName)
{
  var uploadFile = document.getElementById(fieldName);

  if (uploadFile.files.length > 0)
  {
    for (var i = 0; i <= (uploadFile.files.length - 1); i++)
    {
        var fsize    = uploadFile.files.item(i).size;
        var fileSize = Math.round((fsize / 1024));

        if (fileSize >= 153600)
          alert("File too Big, please select a file less than 150mb");
    }
  }
}

function validateBack(count)
{
  var result = false;

  if (!formDirty || confirm('Continuing will cause you to lose any unsaved data. Do you want to continue?'))
  {
    if (window.location.hostname == "localhost")
      url = "http://" + window.location.hostname + ':' + window.location.port + "/go_back/" + count;
    else
      url = "https://" + window.location.hostname + "/pact_awc/go_back/" + count;

    window.location.assign(url);
  }

  return(!formDirty);
}

function updateSubmitButton()
{
  formDirty = true;

  $("[id^=update_]").css("background-color","yellow");
  $("[id^=update_]").css("color","black");
  $("[id^=update_]").hide().show(0);
  $(".form-actions").hide().show(0);
}

function setupChangeNotification(formFields, summernoteFields) {
  $('input').each(function(index, data) {
     $(this).data('originalValue', $(this).val());
  });

  if ((typeof formFields !== 'undefined') && (formFields.length > 0))
  {
    for (var i = 0; i < formFields.length; i++)
    {
      $(formFields[i]).focus(function() {
        if ($(this).data('originalValue') != $(this).val())
          updateSubmitButton();
      });

      $(formFields[i]).change(function() {
        updateSubmitButton();
      });
    }
  }
  else
  {
    $(":input").focus(function() {
      if ($(this).data('originalValue') != $(this).val())
        updateSubmitButton();
    });

    $(":input").change(function() {
      updateSubmitButton();
    });
  }

  if (typeof summernoteFields !== 'undefined') 
  {
    for (var j = 0; j < summernoteFields.length; j++)
    {
      $(summernoteFields[j]).summernote({
        callbacks:
        {
          onKeyup: function(e)
          {
            updateSubmitButton();
          }
        }
      });
    }
  }
}

function setupPersistData(fields)
{
  for (var i = 0; i < fields.length; i++)
  {
    var field = document.getElementById(fields[i]);

    if (field === null)
    {
      alert('Field ' + fields[i] + ' not found.');
    }
    else
    {
      if (field.className.includes('summernote'))
        $('#' + field.id).summernote({
          callbacks: {
            onChange: function(contents, $editable) {
              sessionStorage.setItem(this.id, contents);
            }
          }
        });
      else
      {
        field.addEventListener("change", function() {
          if (this.className.includes('boolean'))
          {
            sessionStorage.setItem(this.id, this.checked);
          }
          else if (this.className.includes('select'))
          {
            sessionStorage.setItem(this.id, this.value);
          }
          else if (this.className.includes('summernote'))
          {
            sessionStorage.setItem(this.id, this.summernote('code'));
          }
          else
          {
            sessionStorage.setItem(this.id, this.value);
          }
        });
      }
    }
  }
}

function getPersistData(fields)
{
  for (var i = 0; i < fields.length; i++)
  {
    var field = document.getElementById(fields[i]);

    if (field === null)
    {
      alert('Field ' + fields[i] + ' not found.');
    }
    else
    {
      if (sessionStorage.getItem(field.id))
      {
        if (field.className.includes('boolean'))
        {
          field.checked = sessionStorage.getItem(field.id);
        }
        else if (field.className.includes('select'))
        {
          $("#" + field.id).val(sessionStorage.getItem(field.id));
        }
        else if (field.className.includes('summernote'))
        {
          $("#" + field.id).summernote('code', sessionStorage.getItem(field.id));
        }
        else
        {
          field.value   = sessionStorage.getItem(field.id);
        }
      }
    }
  }
}

function clearPersistData(fields)
{
  for (var i = 0; i < fields.length; i++)
  {
    var field = document.getElementById(fields[i]);

    sessionStorage.removeItem(field.id);
  }
}
