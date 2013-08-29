ocarinaServices = angular.module('ocarinaServices', ['ngResource'])

ocarinaServices.factory 'Pusher', ->
  if Pusher?
    pusher = new Pusher("28d86c309600f754848f")
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

ocarinaServices.factory 'Playlist', ['$http', ($http) ->
  url = "/api/playlists"
  Playlist = (data) ->
    angular.extend(this, data)

  Playlist.getIndex = (id) ->
    $http.get("#{url}.json")

  Playlist.get = (id) ->
    $http.get("#{url}/#{id}.json").then (res) =>
      new Playlist(res.data)

  Playlist.prototype.create = ->
    $http.post("#{url}.json", { playlist: this } )

  Playlist.join = (id, password) ->
    $http.post("#{url}/#{id}/join", { password: password} )

  Playlist.addSongs = (id, songs) ->
    $http.post "#{url}/#{id}/add_songs.json",
      dropbox: songs["dropbox"]
      soundcloud: songs["soundcloud"]

  Playlist.vote = (id, song_id, decision) ->
    $http.post("#{url}/#{id}/playlist_songs/#{song_id}/#{decision}")

  Playlist.getMediaURL = (id, song_id) ->
    $http.get("#{url}/#{id}/playlist_songs/#{song_id}/media_url.json")

  Playlist.getCurrentSong = (id) ->
    $http.get("#{url}/#{id}/current_song_request.json")

  Playlist.respondCurrentSong = (id, song) ->
    $http.post("#{url}/#{id}/current_song_response.json", {song: song} )

  Playlist.songPlayed = (id, song_id) ->
    $http.post("#{url}/#{id}/playlist_songs/#{song_id}/played.json")

  Playlist.skipSongVote = (id, song_id) ->
    $http.post("#{url}/#{id}/playlist_songs/#{song_id}/skip_song_vote.json")

  Playlist
]

ocarinaServices.factory 'User', ['$http', ($http) ->
  url = "/api/users"
  User = (data) ->
    angular.extend(this, data)

  User.get = (id) ->
    $http.get("#{url}/#{id}.json").then (res) =>
      new User(res.data)

  User.getCurrentUser = ->
    $http.get("/api/current_user.json").then (res) =>
      new User(res.data)

  User
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
    Audio.addEventListener "error", (->
      console.log("error playing that song")
      $rootScope.$broadcast("audioError")
    ), false

    Audio
]

ocarinaServices.factory 'Player', ['Audio', (Audio) ->
  Player =
    playlistId: undefined
    audio: Audio
    play: (song) ->
      if angular.isDefined(song)
        Audio.src = song.media_url
      Audio.play()
    pause: ->
      Audio.pause()
    stop: ->
      Audio.pause()

  Player
]

ocarinaServices.factory 'Facebook', ['$http', ($http) ->
  url = "https://graph.facebook.com"
  Facebook = (data) ->
    angular.extend(this, data)

  Facebook.getEvents = (token) ->
    $http.get("#{url}/me/events?fields=name,location,venue,privacy&type=attending&access_token=#{token}")

  Facebook.postOnEvent = (token, id, message, link, name) ->
    caption = "www.playedby.me"
    description = "Share. Vote. Discover"
    $http.post "#{url}/#{id}/feed?access_token=#{token}&message=#{message}&link=#{link}&name=#{name}&caption=#{caption}&description=#{description}"

  Facebook
]
