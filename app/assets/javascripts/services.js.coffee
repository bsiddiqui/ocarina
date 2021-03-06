# API URL
@apiURL = ""

ocarinaServices = angular.module('ocarinaServices', [])

ocarinaServices.factory 'Pusher', ->
  if Pusher?
    pusher = new Pusher("e9eb3f912d37215f7804")
  else
    # if pusher doesn't load
    subscribe: ->
      bind: ->
        true
      unbind: ->
        true

# Uncomment this during development
# Pusher.log = (message) ->
#  window.console.log message if window.console and window.console.log

ocarinaServices.factory 'Authentication', ['$http', ($http) ->
  Authentication = (data) ->
    angular.extend(this, data)

  Authentication.loggedIn = false

  Authentication.setCookie = (c_name, value, exdays) ->
    exdate = new Date()
    exdate.setDate exdate.getDate() + exdays
    c_value = escape(value) + ((if (not (exdays?)) then "" else "; expires=" + exdate.toUTCString()))
    document.cookie = c_name + "=" + c_value

  Authentication.getCookie = (c_name) ->
    c_value = document.cookie
    c_start = c_value.indexOf(" " + c_name + "=")
    c_start = c_value.indexOf(c_name + "=")  if c_start is -1
    if c_start is -1
      c_value = null
    else
      c_start = c_value.indexOf("=", c_start) + 1
      c_end = c_value.indexOf(";", c_start)
      c_end = c_value.length  if c_end is -1
      c_value = unescape(c_value.substring(c_start, c_end))
      c_value

  Authentication.deleteCookie = (c_name) ->
    Authentication.setCookie(c_name, "", -100)

  Authentication.login = ->
    FB.login ((response) ->
      Authentication.loggedIn = true
    ),
      scope: "email,user_events,publish_stream"

  Authentication.logout = ->
    Authentication.deleteCookie("user_id")
    FB.logout()
    Authentication.loggedIn = false

  Authentication.deferDropbox = (user_id) ->
    $http.post "/defer_dropbox_connect", user_id: user_id

  window.fbAsyncInit = ->
    FB.init
      appId: "160916744087752"
      channelUrl: "//localhost:4400/channel.html"
      status: true # check login status
      cookie: true # enable cookies to allow the server to access the session
      xfbml: true # parse XFBML

    FB.Event.subscribe "auth.authResponseChange", (res) ->
      if res.status is "connected"
        return if Authentication.getCookie("user_id")
        auth = res.authResponse
        FB.api '/me?fields=picture,first_name,last_name,email', (res) ->
          authParams =
            id: res.id
            first_name: res.first_name
            last_name: res.last_name
            email: res.email
            image: res.picture.data.url
            access_token: auth.accessToken
          $.get "#{apiURL}/api/users/authenticate.json", authParams, (data) ->
            Authentication.setCookie("user_id", data.id, 1)
            window.location.replace "http://localhost:4400?user_id=#{data.id}"
      else if res.status is "not_authorized"
        # if user logged in but hasn't authed app
      else
        # if user logged out

  Authentication
]

ocarinaServices.factory 'Playlist', ['$http', ($http) ->
  url = apiURL + "/api/playlists"
  Playlist = (data) ->
    angular.extend(this, data)

  Playlist.getIndex = (user_id) ->
    $http.get("#{url}.json")

  Playlist.get = (user_id, playlist_id) ->
    $http.get("#{url}/#{playlist_id}.json",
      params: { user_id: user_id }
    ).then (res) =>
      new Playlist(res.data)

  Playlist.prototype.create = (user_id) ->
    $http.post "#{url}.json",
      user_id: user_id
      playlist: this

  Playlist.join = (user_id, playlist_id, password) ->
    $http.post "#{url}/#{playlist_id}/join",
      user_id: user_id
      password: password

  Playlist.addSongs = (user_id, playlist_id, songs, continuous_play = false) ->
    $http.post "#{url}/#{playlist_id}/add_songs.json",
      user_id: user_id
      dropbox: songs["dropbox"]
      soundcloud: songs["soundcloud"]
      continuous_play: continuous_play

  Playlist.vote = (user_id, playlist_id, song_id, decision) ->
    $http.post "#{url}/#{playlist_id}/playlist_songs/#{song_id}/#{decision}",
      user_id: user_id

  Playlist.getMediaURL = (user_id, playlist_id, song_id) ->
    $http.get "#{url}/#{playlist_id}/playlist_songs/#{song_id}/media_url.json",
      params: { user_id: user_id }

  Playlist.getCurrentSong = (user_id, playlist_id) ->
    $http.get "#{url}/#{playlist_id}/current_song_request.json",
      params: { user_id: user_id }

  Playlist.respondCurrentSong = (user_id, playlist_id, song) ->
    $http.post "#{url}/#{playlist_id}/current_song_response.json",
      user_id: user_id
      song: song

  Playlist.songPlayed = (user_id, playlist_id, song_id, continuous_play = false) ->
    $http.post "#{url}/#{playlist_id}/playlist_songs/#{song_id}/played.json",
      user_id: user_id
      continuous_play: continuous_play

  Playlist.playbackEnded = (user_id, playlist_id) ->
    $http.post "#{url}/#{playlist_id}/playback_ended.json",
      user_id: user_id

  Playlist.skipSongVote = (user_id, playlist_id, song_id) ->
    $http.post "#{url}/#{playlist_id}/playlist_songs/#{song_id}/skip_song_vote.json",
      user_id: user_id

  Playlist
]

ocarinaServices.factory 'User', ['$http', ($http) ->
  url = apiURL + "/api/users"
  User = (data) ->
    angular.extend(this, data)

  User.get = (id) ->
    $http.get("#{url}/#{id}.json").then (res) =>
      new User(res.data)

  User
]

ocarinaServices.factory 'SavedSong', ['$http', ($http) ->
  url = apiURL + "/api/saved_songs"
  SavedSong = (data) ->
    angular.extend(this, data)

  SavedSong.create = (user_id, song) ->
    $http.post "#{url}.json",
        user_id: user_id
        song: song

  SavedSong.delete = (user_id, song_id) ->
    $http.delete "/api/saved_songs/#{song_id}.json",
      params: { user_id: user_id }

  SavedSong
]

ocarinaServices.factory 'Audio', ['$document', '$rootScope',
  ($document, $rootScope) ->
    Audio = $document[0].createElement('audio')
    Audio.preload = "auto"

    Audio.addEventListener "durationchange", (->
      $rootScope.$broadcast("audioDurationchange")
    ), false
    Audio.addEventListener "loadedmetadata", (->
      $rootScope.$broadcast("audioLoadedMetadata")
    ), false
    Audio.addEventListener "timeupdate", (->
      $rootScope.$broadcast("audioTimeupdate")
    ), false
    Audio.addEventListener "progress", (->
      $rootScope.$broadcast("audioProgress")
    ), false
    Audio.addEventListener "ended", (->
      $rootScope.$broadcast("audioEnded")
    ), false
    Audio.addEventListener "error", ((e)->
      $rootScope.$broadcast("audioError")
    ), false

    Audio
]

ocarinaServices.factory 'Player', ['Audio', (Audio) ->
  Player =
    playlistId: undefined
    currentSong: undefined
    audio: Audio
    state: undefined
    play: (song) ->
      if angular.isDefined(song)
        Audio.src = song.media_url
      Audio.play()
      Player.state = 'playing'
    pause: ->
      Audio.pause()
      Player.state = 'paused'
    stop: (playlistId) ->
      Audio.pause()
      Player.currentSong = undefined
      Player.state = undefined
      Player.playlistId = playlistId

  Player
]

ocarinaServices.factory 'Facebook', ['$http', ($http) ->
  api_url   = "http://facebook.com"
  app_id    = '227387824081363'

  Facebook = (data) ->
    angular.extend(this, data)

  Facebook.getEvents = (callback) ->
    FB.api "/me/events?fields=name,picture,location,venue,privacy,start_time,end_time&type=attending", (res) ->
      callback res

  Facebook.postOnEvent = (id, message, link, name) ->
    caption = "www.playedby.me"
    description = "Share. Vote. Discover."
    FB.api "/#{id}/feed?message=#{message}&link=#{link}&name=#{name}&caption=#{caption}&description=#{description}"

  Facebook.sendDialog = (playlist_id) ->
    FB.ui
      method: "send"
      link: "http://played-by-me.herokuapp.com/playlists/#{playlist_id}"

  Facebook.getUsersFavoriteArtists = (id, callback) ->
    FB.api "/#{id}/music", (res) ->
      artists = []
      _.each res.data.data, (artist) ->
        artists.push(artist.name)
      callback artists

  Facebook.getPartiesFavoriteArtists = (ids, callback) ->
    query = encodeURIComponent "SELECT music FROM user WHERE uid IN (#{ids})"
    FB.api "/fql?q=#{query}", (res) ->
      callback getSortedArtists(res.data)

  Facebook.getEventsFavoriteArtists = (event_id, callback) ->
    query = encodeURIComponent "SELECT music FROM user WHERE uid IN (SELECT uid FROM event_member WHERE eid=#{event_id} AND rsvp_status='attending') AND uid IN (SELECT uid2 FROM friend WHERE uid1 = me())"
    FB.api "/fql?q=#{query}", (res) ->
      callback getSortedArtists(res.data)

  getSortedArtists = (data) ->
    # find like count per artists
    groupedArtists = {}
    _.each data, (user) ->
      artists = user.music.split(", ")
      _.each artists, (artist) ->
        unless artist is ""
          if groupedArtists[artist]
            groupedArtists[artist]++
          else
            groupedArtists[artist] = 1

    # categorize artists by like count
    ranks = {}
    max_rank = 0
    for artist of groupedArtists
      max_rank = groupedArtists[artist] if groupedArtists[artist] > max_rank
      if ranks[groupedArtists[artist]]
        ranks[groupedArtists[artist]].push artist
      else
        ranks[groupedArtists[artist]] = [artist]

    # add artists to array in order of rank
    sortedArtists = []
    i = max_rank
    while i > 0
      sortedArtists = sortedArtists.concat(ranks[i] or [])
      i--

    sortedArtists

  Facebook
]
