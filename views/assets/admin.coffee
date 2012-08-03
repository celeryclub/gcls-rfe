$ ->

  # fix_helper = (e, ui) ->
  #   ui.children().each( ->
  #     $(this).width($(this).width())
  #   )
  #   return ui;

  $('.sortable').disableSelection()
  # Table fix
  # $('.sortable').on('mousedown', ->
  #   $(this).find('td').each( -> $(this).width($(this).width()) )
  #   # console.log $(this)
  # )
  $('.sortable').sortable({
    # cursor: 'move'
    # helper: 'clone'
    # helper: 'fix_helper'
    # forceHelperSize: true
    # stop: (e, tr) ->
    #   # console.log $(this)
    #   $(this).find('td').each( -> $(this).width('auto') )
    #   # tr.item.children().each( (i, td) ->
    #     # Set helper cell sizes to match the original sizes
    #     # $(this).width('')
    #     # $(this).height(originals.eq(i).height())
    #   # )
    # helper: (e, ui) ->
    #   originals = ui.children()
    #   helper = ui.clone()
    #   helper.children().each( (i) ->
    #     # Set helper cell sizes to match the original sizes
    #     $(this).width(originals.eq(i).width())
    #     # $(this).height(originals.eq(i).height())
    #   )
    #   helper
    handle: '.handle'
    axis: 'y'
    update: (e, ui) ->
      # container = ui.item.parent()
      positions = $(this).sortable('serialize')
      put_to = $(this).attr('data-url')
      console.log positions
      # console.log put_to
      $.ajax({
        type: 'PUT'
        url: put_to
        data: positions
        # ,
        # success: success,
        # dataType: dataType
      })
  })

  $('.btn.btn-danger').on('click', -> false unless confirm 'Are you sure?')

  $(document).on(
    'keydown'
    (e) ->
      # console.log e.which
      # Cancel drag
      if e.which == 27
        $('.sortable').sortable('cancel')
#       # Next post
#       else if e.which == 39
#         newer = $('.newer').find('a')
#         if newer.length > 0
#           window.location = newer.attr('href')
  )

# strip_trailing_slash = (str) ->
#   if str.substr(-1) == '/'
#     str.substr(0, str.length - 1)
#   str
