var cs = angular.module("cs", []);

cs.controller("main",['$rootScope','$scope','$http','$log',function ($scope,$http,$log) {
    $http.get("api/ResourceJ/"+$scope.resource).then(function(xs){
        $scope.questionario=xs.data.result;
        $log.log(xs.data);
        });

    $scope.selected=null;
    $scope.selectedClass = function (index)  {
        if(index==$scope.selected) return "selected"
        return "unselected"
        }
}]);




