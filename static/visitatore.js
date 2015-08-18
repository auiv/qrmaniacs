var myApp = angular.module("myApp", []);

myApp.controller("main",['$scope','$http','$log','$timeout',function ($scope,$http,$log,$timeout) {
    $timeout(
        function ()  {
                $http.get("ResourceJ/"+$scope.resource).then(
                        function(xs){
                                $scope.questionario=xs.data.result;
                                $log.log(xs.data);}
                        );
                }
        );
    $scope.feedback = function(d,r){
                $http.put("AddFeedback/"+d+"/"+r).then(
                        function(){}
                        );}
    $scope.selected=null;
    $scope.selectedClass = function (index)  {
        if(index==$scope.selected) return "selected"
        return "unselected"
        }
}]);




