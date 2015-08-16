

var myApp = angular.module("myApp", ["xeditable",'ngRoute','cs']);

myApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/', {
        templateUrl: 'argomenti.html',
        controller: 'ArgomentiController'
      }).
      when('/Resource/:hash', {
        templateUrl: 'domande.html',
        controller: 'DomandeController'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);

myApp.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});



