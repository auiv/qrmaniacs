
var cs = angular.module("cs", ["xeditable",'ui.bootstrap','ngCookies']);

cs.controller('Input', function ($scope, $modalInstance) {

          $scope.gotMessage = function () {
            $modalInstance.close();
          };

          $scope.cancel = function () {
            $modalInstance.dismiss('cancel');
          };
        });
cs.controller("LogoutController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies) {
    $scope.cookie = $cookies.get("userName");
    $scope.logout = function () {
        $http.get("Logout").then(function(xs){
                        $location.url("/");
                        });
        }
        }
        );
cs.factory('Page', function() {
   var title = 'default';
   return {
     title: function() { return title; },
     setTitle: function(newTitle) { title = newTitle; }
   };
});
cs.controller("title",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page) {
        $scope.Page=Page; 
        }
        );
cs.controller("AutoreController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page,$window) {
    $scope.goBack = function () {$window.history.back()};
    $scope.selected=null;
    $scope.argomenti = [];
    Page.setTitle("Autore di QR");
    $timeout(function () {$scope.cookie = $cookies.get("userName")});
    $scope.update_ = function (f) {
                $http.get("Argomenti").then(function(xs){
                        $scope.argomenti=xs.data.result;
                        $log.log(xs.data);
                        f();
                        });
        }
   $scope.update=function(){$scope.update_(function(){})};
        $scope.update();
   $scope.input={};
   $scope.qr=function(h){
         window.location.href = "QR/"+h;
        }

   $scope.qrpersonal=function(){
         window.location.href = "QR";
        }
   $scope.qridentify=function(){
         window.location.href = "QR/Identify";
        }
   $scope.gotoResource = function(i) {
        $location.url("/Resource/"+i);
        }
   $scope.gotoEditResource = function(i) {
        $location.url("/Autore/Resource/"+i);
        }
   $scope.gotoQR = function(i) {
        window.location.href="QR/"+i;
        }
     $scope.checkDelete = function (f,i) {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'static/deleting.html',
                        controller: 'Input',
                        size: 'lg',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {f(i);},
                        function () {}
                        );
                };

      $scope.addArgomento = function () {
                                $http.post("AddArgomento","argomento ...").
                                        success(function(){
                                                $scope.update_(function(){
                                                $location.url("/Autore/Resource/" + $scope.argomenti[$scope.argomenti.length-1].index);
                                                });
                                        })
                                        
                                }; 

    $scope.selectedClass = function (index)  {
        if(index==$scope.selected) return "selected"
        return "unselected"
        }
    $scope.changeArgomento = function(value,index)  {
        $http.post("ChangeArgomento/" + index,value);
        }
    $scope.deleteArgomento = function(index)  {
        $http.put("DeleteArgomento/" + index).success($scope.update);
        }
});

cs.controller("VisitatoreController",function ($scope,Page,$http,$window) {
    $scope.goBack = function () {$window.history.back()};
    Page.setTitle("Visitatore");
    $scope.update = function () {
                $http.get("Visitati").then(function(xs){
                        $scope.argomenti=xs.data.result;
                        $log.log(xs.data);
                        });
        }
    $scope.update();

});
 
cs.controller("HomeController",function ($scope,$http,$modal,$timeout,$interval,$log,$routeParams,$cookies,$location,$route,Page) {
        $scope.cookie=$cookies.get("userName");
        Page.setTitle("QR Maniacs");
        $scope.qrlogin=function(){
                window.location.href = "QR/Login";
        }
    });  

cs.controller("DomandeVisitatoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window,$cookies) {
    $scope.goBack = function () {$window.history.back()};
    Page.setTitle("Visitatore di QR"); 
    $scope.feedback= function (r) {
                $http.put("AddFeedback/"+r).success(function(xs){
                        });}
    $scope.items = [];
    $scope.hash = $routeParams.hash;
    $scope.update = function () {
                $http.get("ChangeAssoc/"+$scope.hash).success(function(xs){
                        $scope.items=xs.result.domande;
                        $scope.author=xs.result.autore;
                        $scope.argomento={'text':xs.result.text};
                        });
                }
   $scope.update();
        
        });
cs.controller("DomandeAutoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
    $scope.goBack = function () {$window.history.back()};
    Page.setTitle("Autore domande QR");
    $scope.items = [];
    $scope.valori=['Giusta','Sbagliata','Accettabile'];
    $scope.hash = $routeParams.hash;
    $scope.update_ = function (f) {
                $http.get("Domande/"+$scope.hash).success(function(xs){
                        $scope.items=xs.result.domande;
                        $scope.argomento={'text':xs.result.text};
                        f();
                        });
                }
   $scope.update=function(){$scope.update_(function(){})};
   $scope.update();
                
   $scope.input={};

     $scope.checkDelete = function (f,i) {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'static/deleting.html',
                        controller: 'Input',
                        size: 'lg',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {f(i);},
                        function () {}
                        );
                };

      $scope.addDomanda = function (i) {
                                $http.post("AddDomanda/"+ $scope.hash,"domanda ...").success($scope.update);};
                
      $scope.addRisposta = function (i) {
                                $http.post("AddRisposta/"+ i + "/Accettabile" ,"risposta ...").success($scope.update);} 

    $scope.changeDomanda = function(value,index)  {
        return $http.post("ChangeDomanda/" + index,value);
        }
    $scope.deleteDomanda = function(index)  {
        $http.put("DeleteDomanda/" + index).success($scope.update);
        }
    $scope.deleteRisposta = function(index)  {
        $http.put("DeleteRisposta/" + index).success($scope.update);
        }
    
    $scope.changeRisposta = function(value,index)  {
        return $http.post("ChangeRisposta/" + index,value);
        }
    $scope.changeRispostaValue = function(value,index)  {
        return $http.put("ChangeRispostaValue/" + index + "/" + value);
        }
});


