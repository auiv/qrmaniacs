

var myApp = angular.module("myApp", ["xeditable",'ngRoute','cs']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'static/home.html',
        controller:'HomeController'
      }).
      when('/common', {
        templateUrl: 'static/common.html',
        controller:'CommonController'
      }).
      when('/Autore', {
        templateUrl: 'static/argomenti.html',
        controller: 'AutoreController'
      }).
      when('/Visitatore', {
        templateUrl: 'static/visitatore.html',
        controller: 'VisitatoreController'
      }).
      when('/Validatore', {
        templateUrl: 'static/validatore.html'
        //controller: 'VisitatoreController'
      }).
      when('/Autore/Resource/:hash', {
        templateUrl: 'static/domande.html',
        controller: 'DomandeAutoreController'
      }).
      when('/Resource/:hash', {
        templateUrl: 'static/domandev.html',
        controller: 'DomandeVisitatoreController'
      }).
      when('/Logout', {
        templateUrl: 'static/logout.html',
        controller: 'LogoutController'
      }).
      when('/loggedout', {
        templateUrl: 'static/loggedout.html',
        controller: 'LoggedOutController'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

myApp.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});



