

var myApp = angular.module("myApp", ["xeditable",'ngRoute','cs']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'static/home.html',
        controller: 'HomeController'
      }).
      when('/Risposte', {
        templateUrl: 'static/risposte.html',
        controller: 'RisposteController'
      }).
      when('/Profile', {
        templateUrl: 'static/profile.html',
        controller:'ProfileController'
      }).
      when('/Campagna', {
        templateUrl: 'static/campagna.html',
        controller:'CampagnaController'
      }).
      when('/Autore', {
        templateUrl: 'static/questionari.html',
        controller: 'QuestionariController'
      }).
      when('/Autore/Resource/:hash', {
        templateUrl: 'static/domande.html',
        controller: 'DomandeAutoreController'
      }).
      when('/Resource/:hash', {
        templateUrl: 'static/domandev.html',
        controller: 'DomandeVisitatoreController'
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
      otherwise({
        redirectTo: '/'
      });
  }]);

myApp.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});



