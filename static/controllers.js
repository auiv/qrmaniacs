
var cs = angular.module("cs", ["xeditable",'ui.bootstrap','ngCookies']);


cs.factory('Page', function($location,$window) {
   var title = 'default';
   return {
     title: function() { return title; },
     setTitle: function(newTitle) { title = newTitle; },
     qr: function(h){
         window.location.href = "QR/"+h;
        },

     qrpersonal:function(){
         window.location.href = "QR";
        },
      qridentify:function(){
         window.location.href = "QR/Identify";
        },
      gotoResource:function(i) {
        $location.url("/Resource/"+i);
        },
       gotoEditResource :function(i) {
        $location.url("/Autore/Resource/"+i);
        },
        gotoQR :function(i) {
        window.location.href="QR/"+i;
        },
        goBack : function () {window.history.back()}
   };
});

cs.controller('Input', function ($scope, $modalInstance) {
          $scope.gotMessage = function () {$modalInstance.close();};
          $scope.cancel = function () {$modalInstance.dismiss('cancel');};
        });

cs.controller("LogoutController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies) {
    $scope.cookie = $cookies.get("userName");
        $scope.qrlogin=function(){window.location.href = "QR/Login";}
    $scope.logout = function () {
        $http.get("Logout").then(function(xs){$location.url("/");});
        }
    });

cs.controller("title",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page) {
        $scope.Page=Page; 
        });

cs.controller("AutoreController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page,$window) {
    $scope.Page=Page;
    Page.setTitle("Autore di QR");
    
    $scope.selected=null;
    $scope.argomenti = [];
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
    $scope.deleteArgomento = function(index)  {
        $http.put("DeleteArgomento/" + index).success($scope.update);
        }
});

cs.controller("VisitatoreController",function ($scope,Page,$http,$window,$location,Page) {
    $scope.Page = Page;
    Page.setTitle("Visitatore");
    $scope.update = function () {
                $http.get("Visitati").then(function(xs){
                        $scope.argomenti=xs.data.result;
                        });
        }
    $scope.update();
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
     $scope.deleteArgomento = function(i) {
        $http.put("RemoveFeedback/"++i).success(function (){$scope.update()})}
});
 
cs.controller("HomeController",function ($scope,$http,$modal,$timeout,$interval,$log,$routeParams,$cookies,$location,$route,Page) {
        var a = $cookies.get("userName");
        if(a){$scope.user=a.slice(1,6)};
        
        $scope.active=false;
        $http.get("Role").success(function(xs){
                $scope.isAuthor=xs.result.author;
                $scope.isValidatore=xs.result.validatore;
                $scope.active=true;
                });
        Page.setTitle("QR Maniacs");
    });  

cs.controller("DomandeVisitatoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window,$cookies) {
    $scope.Page = Page;
    Page.setTitle("Visitatore di QR"); 
    $scope.feedback= function (r) {
                $http.put("AddFeedback/"+r).success(function(xs){
                $scope.update();
                        });}
    $scope.items = [];
    $scope.hash = $routeParams.hash;
    $scope.update = function () {
                $http.get("ChangeAssoc/"+$scope.hash).success(function(xs){
                        $scope.author=xs.result.author;
                        $scope.items=xs.result.domande;
                        $scope.argomento={'text':xs.result.text};
                        });
                }
   $scope.update();
        
        });
cs.controller("DomandeAutoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
    $scope.Page = Page;
    Page.setTitle("Autore domande QR");
    $scope.items = [];
    $scope.valori=['Giusta','Sbagliata','Accettabile'];
    $scope.hash = $routeParams.hash;
    $scope.update_ = function (f) {
                $http.get("DomandeAutore/"+$scope.hash).success(function(xs){
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
    
    $scope.changeArgomento = function(value)  {
        return $http.post("ChangeArgomento/" + $scope.hash,value);
        }
    $scope.changeRisposta = function(value,index)  {
        return $http.post("ChangeRisposta/" + index,value);
        }
    $scope.changeRispostaValue = function(value,index)  {
        return $http.put("ChangeRispostaValue/" + index + "/" + value);
        }
});


