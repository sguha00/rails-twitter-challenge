@app.controller("FollowersController", ['$scope', '$http', ($scope, $http) -> 
  $scope.processing = false

  $scope.getFollowers = ->
    if $scope.username1 && $scope.username2
      $scope.processing = true
      $scope.followers = []
      $scope.error = false
      $http.get('/followers/' + $scope.username1 + '/' + $scope.username2 + '.json').
        success((data, status, headers, config) -> 
          console.log(data)
          $scope.followers = data
        ).
        error((data, status, headers, config) ->
          delete $scope.followers
          $scope.error = data.error
        ).
        finally(() ->
          $scope.processing = false
        )
])