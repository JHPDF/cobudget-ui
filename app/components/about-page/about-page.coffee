module.exports =
  url: '/about1'
  template: require('./about-page.html')
  controller: ($location, $scope) ->

    $scope.redirectToLandingPage = ->
      $location.path('/')

    return
