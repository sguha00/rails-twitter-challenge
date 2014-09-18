@app.controller("TweetsController", ['$scope', '$http', ($scope, $http) -> 

  $scope.getTweets = ->
    if $scope.username
      $scope.processing = true
      $scope.tweets = []
      $scope.error = false
      $http.get('/tweets/' + $scope.username + '.json').
        success((data, status, headers, config) -> 
          $scope.tweets = data
        ).
        error((data, status, headers, config) ->
          $scope.error = data.error
        ).
        finally(() ->
          $scope.processing = false
        )
])