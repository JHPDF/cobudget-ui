module.exports =
  resolve:
    userValidated: ($auth) ->
      $auth.validateUser()
    membershipsLoaded: ->
      global.cobudgetApp.membershipsLoaded
  url: '/buckets/:bucketId'
  template: require('./bucket-page.html')
  controller: (CurrentUser, Error, LoadBar, $location, Records, $scope, $stateParams, Toast, UserCan, $window) ->

    LoadBar.start()
    bucketId = parseInt $stateParams.bucketId
    Records.buckets.findOrFetchById(bucketId)
      .then (bucket) ->
        if UserCan.viewBucket(bucket)
          $scope.authorized = true
          Error.clear()
          $scope.currentUser = CurrentUser()
          $scope.bucket = bucket
          $scope.group = bucket.group()
          $scope.membership = $scope.group.membershipFor(CurrentUser())
          Records.contributions.fetchByBucketId(bucketId).then ->
            $scope.contributions = $scope.bucket.contributions()
            $window.scrollTo(0,0)
            LoadBar.stop()
          Records.comments.fetchByBucketId(bucketId)
        else
          $scope.authorized = false
          LoadBar.stop()
          Error.set('cannot view bucket')
      .catch ->
        LoadBar.stop()
        Error.set('bucket not found')

    $scope.newContribution = Records.contributions.build(bucketId: bucketId)

    $scope.back = ->
      Toast.hide()
      $location.path("/groups/#{$scope.group.id}")

    $scope.userCanManageBucket = ->
      $scope.bucket && !$scope.bucket.paidAt && $scope.bucket.status != 'refunded' && !($scope.bucket.archivedAt && $scope.bucket.status == 'draft') && !($scope.bucket.archivedAt && $scope.bucket.status == 'live') && ($scope.membership.isAdmin || $scope.bucket.author().id == $scope.membership.member().id)

    return
