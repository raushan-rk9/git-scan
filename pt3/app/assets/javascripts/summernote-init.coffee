$(document).on 'turbolinks:load', ->
  $('[data-provider="summernote"]').each ->
    $(this).summernote
      height:  300
      fontSizes: ['8', '9', '10', '11', '12', '13', '14', '16', '18', '24', '36', '72' ]
      fontNames: ['arial', 'Courier New', 'helvetica', 'Tahoma', 'Times New Roman', 'verdana']
      toolbar: [
                 ['style',    ['bold', 'italic', 'underline', 'clear']],
                 ['font',     ['strikethrough', 'superscript', 'subscript']],
                 ['fontname', ['fontname']],
                 ['fontsize', ['fontsize']],
                 ['color',    ['color']],
                 ['para',     ['ul', 'ol', 'paragraph']],
                 ['height',   ['height']]
                 ['table', ['table']],
                 ['insert', ['link', 'picture', 'video']],
                 ['view', ['fullscreen', 'codeview', 'help']]
               ]
