# sets up angular app
@ocarina = angular
  .module('ocarina', ['ocarinaServices', 'ocarinaFilters', 'ocarinaDirectives'])
  .config(['$locationProvider', '$routeProvider', '$httpProvider',
    ($locationProvider, $routeProvider, $httpProvider) ->

      $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')

      $locationProvider.html5Mode(true)

      $routeProvider
        .when '/playlists/:playlistId',
          templateUrl: '/partials/playlists/show.html'
        .when '/playlists/:playlistId/add_songs',
          templateUrl: '/partials/playlists/add_songs.html'
        .when '/',
          templateUrl: '/partials/profile.html'
        .otherwise
          redirectTo: '/'
  ])
  .run(['$rootScope', '$location', ($rootScope, $location) ->
    $rootScope.location = $location
  ])
