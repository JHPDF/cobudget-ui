angular.module('bucket-list', [])
  .controller 'BucketListCtrl', ($scope, $stateParams, RoundService, ContributionService, AuthService, BucketService, latestRound) ->

    ///Lots of this should be abstracted into a service///

    $scope.currentUserId = AuthService.getCurrentUser().id

    $scope.loadContributorDetails = () ->
      RoundService.getContributorDetails($scope.round.id, $scope.currentUser.id).then (details) ->
        $scope.myRoundDetails = details
        $scope.round.myAllocationsLeftCents = details.fundsLeftCents
        $scope.round.myAllocationsAmountCents = details.allocationAmountCents
        $scope.status = $scope.round.getStatus()

    $scope.saveContribution = (contribution) ->
      # if we're gonna have a bad time
      if $scope.status == 'warning'
        # gtfo
        return
      contribution.save(ContributionService).then ->
        $scope.loadContributorDetails()

    $scope.groupId = $stateParams.groupId
    $scope.status = null

    round = latestRound
    $scope.round = round
    $scope.loadContributorDetails()

    _.each round.buckets, (bucket, index) ->
      # get current user's contribution
      myContribution = bucket.getMyContribution($scope.currentUserId)
      bucket.getPercentageFunded()
      bucket.getMyContributionPercentage()
      bucket.getGroupContribution()

      $scope.$watch "round.buckets["+index+"].myContribution.amountDollars", (amountDollars, oldAmountDollars) ->

        # if amountDollars is Not a Number (NaN)
        if amountDollars != 0 and not amountDollars
          # don't accept number
          bucket.myContribution.amountDollars = oldAmountDollars

        round.getMyAllocationsLeftCents(round.myAllocationsAmountCents)

        if round.myAllocationsLeftCents < 0
          bucket.myContribution.amountCents += round.myAllocationsLeftCents

        $scope.status = round.getStatus()

        if amountDollars >= 0
          bucket.getMyContributionPercentage()
          # ensure progress bar does not overfill
          bucket.myContributionPercentage = Math.min(bucket.myContributionPercentage, 100 - bucket.groupContributionPercentage)

    round.getMyContributions()

    #Find total cents contributed to round for bucket list sum
    totalCentsContributed = 0
    for bucket in $scope.round.buckets
      totalCentsContributed += bucket.contributionTotalCents

    #Find total round funds for bucket list sum
    roundFundsTotalCents = 0
    for allocation in $scope.round.allocations
      roundFundsTotalCents += allocation.amountCents

    $scope.round.totalAllocable = roundFundsTotalCents / 100
    $scope.round.totalAllocated = totalCentsContributed / 100
    $scope.round.timeLeftDays = 3
    $scope.round.timeLeftHours = 72