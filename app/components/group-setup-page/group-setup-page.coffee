# http://i.imgur.com/RMs4njZ.gifv

module.exports =
  onEnter: ($location) ->
    $location.url($location.path())
  resolve:
    userValidated: ($auth) ->
      $auth.validateUser()
    membershipsLoaded: ->
      global.cobudgetApp.membershipsLoaded
  url: '/setup_group'
  template: require('./group-setup-page.html')
  controller: (LoadBar, Records, $scope, $state) ->

    $scope.createGroup = (formData) ->
      LoadBar.start()
      Records.groups.build(name: formData.name, currencyCode: formData.currency.code, currencySymbol: formData.currency.symbol).save().then ->
        Records.memberships.fetchMyMemberships().then (data) ->
          newGroup = _.find data.groups, (group) ->
            group.name == formData.name
          $state.go('group', {groupId: newGroup.id, firstTimeSeeingGroup: true})
          LoadBar.stop()

    $scope.currencies = [
      { code: 'USD', symbol: '$' },
      { code: 'NZD', symbol: '$' },
      { code: 'CAD', symbol: '$' },
      { code: 'GBP', symbol: '£' },
      { code: 'EUR', symbol: '€' },
      { code: 'CHF', symbol: 'CHF' },
      { code: 'JPY', symbol: '¥' }
    ]
