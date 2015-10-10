var module = angular.module('controllers', ['page']);

module.controller('HomeController',function ($scope,$resource,Page) {
    $scope.Page=Page;
    Page.setTile("Home");
    });


var module = angular.module("qrmaniacs", ["xeditable",'ngRoute','page','controllers']);

module.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'static/home.html',
        controller: 'HomeController'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

module.controller("title",function ($scope,Page) {
        $scope.Page=Page;
        $scope.isViewLoading = false;
        $scope.$on('$routeChangeStart', function() {
          $scope.isViewLoading = true;
        });
        $scope.$on('$routeChangeSuccess', function() {
          $scope.isViewLoading = false;
        });
        $scope.$on('$routeChangeError', function() {
          $scope.isViewLoading = false;
        })
        });
module.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});



