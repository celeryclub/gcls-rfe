$ ->

  # fix_helper = (e, ui) ->
  #   ui.children().each( ->
  #     $(this).width($(this).width())
  #   )
  #   return ui;

  $('.sortable').disableSelection()
  # $('.sortable').on('mousedown', ->
  #   console.log $(this).height()
  #   console.log $(this).innerHeight()
  #   console.log $(this).outerHeight(true)
  #   $(this).height($(this).outerHeight(true))
  #   # $(this).height($(this).height())
  # #   $(this).find('ul').each( -> $(this).height($(this).height()) )
  # #   console.log $(this)
  # )
  $('.sortable').sortable({
    # Watch out for min-height on sortable children
    create: -> $(this).height($(this).height())
    # create: -> $(this).height($(this).outerHeight(true))
    # stop: -> $(this).height('auto')
    # stop: (e, ui) ->
      # ui.item.height('auto')
    #   # console.log $(this)
    #   $(this).find('td').each( -> $(this).width('auto') )
    #   # tr.item.children().each( (i, td) ->
    #     # Set helper cell sizes to match the original sizes
    #     # $(this).width('')
    #     # $(this).height(originals.eq(i).height())
    #   # )
    # helper: (e, ui) ->
      # $(ui).height($(ui).height())
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
  
  $('.btn-danger').on('click', -> false unless confirm 'Are you sure?')

  filter_sections()
  $('.link-form').find('#page_id').on('change', filter_sections)
  # $('.link-form').find('#page_id').on('change', -> console.log('hey'))

  $(document).on(
    'keydown'
    (e) ->
      # Cancel drag
      if e.which == 27
        $('.sortable').sortable('cancel')
  )

original_sections = $('#section_id').find('option')
filter_sections = ->
  section_container = $('#section_id')
  section_group = section_container.closest('.control-group')
  selected_page_id = $('#page_id').find('option:selected').attr('value')
  section_container.html(original_sections)
  original_sections.each( ->
    if $(this).attr('data-page-id') && $(this).attr('data-page-id') != selected_page_id then $(this).remove()
  )
  if section_container.find('option').length == 1
    section_group.hide()
  else
    section_group.show()
