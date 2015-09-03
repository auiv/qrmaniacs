

var myApp = angular.module("myApp", ["xeditable",'ngRoute','cs']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'static/visitatore.html',
        controller: 'VisitatoreController'
      }).
      when('/Profile', {
        templateUrl: 'static/home.html',
        controller:'HomeController'
      }).
      when('/Sistema', {
        templateUrl: 'static/common.html',
        controller:'CommonController'
      }).
      when('/Autore', {
        templateUrl: 'static/argomenti.html',
        controller: 'AutoreController'
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
      when('/eliminated', {
        templateUrl: 'static/eliminated.html',
        controller: 'LoggedOutController'
      }).
      when('/CantPromote/:reason', {
        templateUrl: 'static/cantpromote.html',
        controller: 'CantPromoteController'
      }).
      when('/CantValidate/:reason', {
        templateUrl: 'static/cantvalidate.html',
        controller: 'CantValidateController'
      }).
      when('/Promoted', {
        templateUrl: 'static/promoted.html',
        controller: 'PromotedController'
      }).
      when('/Validated', {
        templateUrl: 'static/validated.html',
        controller: 'ValidatedController'
      }).
      when('/Confirmed', {
        templateUrl: 'static/confirmed.html',
        controller: 'ConfirmedController'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

myApp.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});



