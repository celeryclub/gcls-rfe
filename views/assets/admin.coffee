$(document).onReady ->
  "#main".onClick ->
    console.log 'clicked'

# $ ->

  # transition_speed = 300

#   $('.btn.btn-danger').on('click', -> false unless confirm 'Are you sure?')

#   $('.post').fitVids()

#   dlp = strip_trailing_slash(document.location.pathname)
#   key_last = null
#   key_count = null
#   $(document).on(
#     'keydown'
#     (e)->
#       # Previous post
#       if e.which == 37
#         older = $('.older').find('a')
#         if older.length > 0
#           window.location = older.attr('href')
#       # Next post
#       else if e.which == 39
#         newer = $('.newer').find('a')
#         if newer.length > 0
#           window.location = newer.attr('href')
#       # Multiple key press
#       else if e.which == key_last
#         key_count++
#         if key_count >= 3 && e.which == 13
#           # New post
#           if dlp == '/blog'
#             window.location = '/blog/new'
#           # Edit post
#           else if dlp.indexOf('/blog') >= 0 && dlp.indexOf('/edit') < 0
#             post_id = $('.post').attr('id').replace('post-', '')
#             window.location = "/blog/#{post_id}/edit"
#       else
#         key_count = 1
#       key_last = e.which
#       # console.log key_count
#   )

#   lastfm_recent()
#   # setInterval(lastfm_recent(), 5000)


# strip_trailing_slash = (str) ->
#   if str.substr(-1) == '/'
#     str.substr(0, str.length - 1)
#   str

# lastfm_recent = ->
#   api_key = '3b542380a2728ae170a8b50184d9eb40'
#   user = 'stephendavis89'
#   format = 'json'
#   limit = 4
#   $('.lastfm').find('.tracks').html('')
#   data_url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{user}&limit=#{limit}&format=#{format}&api_key=#{api_key}"
#   console.log data_url
#   $.getJSON(
#     data_url
#     (data) ->
#       # console.log data
#       prev_img = ''
#       for track, i in data.recenttracks.track
#         # console.log "Name: #{track.name} / Artist: #{track.artist['#text']} / Album: #{track.album['#text']} / Image: #{track.image[3]['#text']}"
#         if i < limit
#           htm = "<div class='track'><img class='track-cover"
#           current_img = track.image[0]['#text']
#           if current_img == prev_img
#             htm += " duplicate"
#           prev_img = current_img
#           htm += "' src='#{current_img}'><span class='name'>#{track.name}</span><small class='artist'>#{track.artist['#text']}</small>"
#           htm += "</div>"
#           # $('.lastfm').find('.tracks').append(htm).hide().slideDown(300)
#           $('.lastfm').find('.tracks').append(htm)
#       console.log $('.lastfm').find('.track').hide().first().show(150, show_next = ->
#         $(this).next('.track').show(150, show_next);
#       )
#   )
