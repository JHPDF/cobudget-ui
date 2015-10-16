module.exports =
  resolve:
    membershipsLoaded: ->
      global.cobudgetApp.membershipsLoaded
  url: '/groups/:groupId'
  template: require('./group-page.html')
  controller: (CurrentUser, Error, Records, $scope, $stateParams, UserCan) ->

    groupId = parseInt($stateParams.groupId)
    Records.groups.findOrFetchById(groupId)
      .then (group) ->
        if UserCan.viewGroup(group)
          $scope.authorized = true
          Error.clear()
          $scope.group = group
          $scope.currentUser = CurrentUser()
          $scope.membership = group.membershipFor(CurrentUser())
          Records.memberships.fetchByGroupId(groupId)
          Records.buckets.fetchByGroupId(groupId)
          Records.contributions.fetchByGroupId(groupId)
        else
          $scope.authorized = false
          Error.set('cannot view group')
      .catch ->
        Error.set('group not found')

    return