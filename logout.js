


var myApp = angular.module("logout", ['ngRoute']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      otherwise({
        redirectTo: '/'
      });
  }]);

myApp.controller("main",  ['$scope',function($scope){}]);


