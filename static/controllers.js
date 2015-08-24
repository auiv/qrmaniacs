
var cs = angular.module("cs", ["xeditable",'ui.bootstrap','ngCookies']);

cs.run(function(editableOptions) {
  editableOptions.theme = 'bs2';
});

cs.factory('Page', function($location,$window,$cookies) {
   var title = 'default';
   var logo = "";
   var unlogged=false;
   return {
        title: function() { return title; },
        setTitle: function(newTitle) { title = newTitle; },
        logo: function(newTitle) {return logo},
        setLogo: function(newLogo) { logo = newLogo},
        qr: function(h){window.location.href = "QR/"+h},
        qrpersonal:function(){window.location.href = "QR"},
        qridentify:function(){window.location.href = "QR/Identify"},
        gotoResource:function(i) {$location.url("/Resource/"+i)},
        gotoEditResource :function(i) {$location.url("/Autore/Resource/"+i)},
        gotoQR :function(i) {window.location.href="QR/"+i},
        goBack : function () {window.history.back()},
        user : function (){return $cookies.get("userName")},
        loginQR : function(){window.location.href = "QR/Login"},
        setUnlogged: function (){unlogged=true},
        unlogged: function(){if(unlogged)window.history.back()}
        };
        });
cs.controller('Input', function ($scope, $modalInstance) {
          $scope.gotMessage = function () {$modalInstance.close();};
          $scope.cancel = function () {$modalInstance.dismiss('cancel');};
        });

cs.controller('LoggedOutController', function () {
        });
cs.controller("HomeController",function ($scope,$http,Page,$modal,$location) {
        $scope.Page=Page; 
        Page.setTitle("QR Maniacs");
        Page.setLogo("static/immagini/logo.png");
        $scope.active=false;
        $scope.campagna={};
        $scope.campagna.hour=new Date();
        $scope.$watch('campagna',function(a,b) {alert(a)});
        $scope.changeLogo = function (x) {
                alert(1);
                return true;
                }
        $scope.updateMail = function (d) {
                return $http.put("SetMail/" + d).success(function(xs){$scope.update()});
                }
        $scope.logout = function () {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'static/logginout.html',
                        controller: 'Input',
                        size: 'lg',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {$http.get("Logout").then(function(xs){$location.url("/loggedout");})},
                        function () {}
                        );
                };
        $scope.confermato = function () {
                if($scope.conferma) return 'confermato';
                return "non confermato";
                }
        $scope.update = function (f) {
         $http.get("Role").success(function(xs){
                $scope.isAuthor=xs.result.author;
                $scope.isValidatore=xs.result.validatore;
                $scope.mail=xs.result.email;
                $scope.conferma=xs.result.conferma;
                $scope.campagna = xs.result.campagna;
                $scope.active=true;
                });
        }
        $scope.update();

    });  

cs.controller("LogoutController",function ($scope,$http,$log,$location,Page) {
        $scope.Page = Page;
        Page.setLogo("static/immagini/logo.png");
        });

cs.controller("title",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page) {
        $scope.Page=Page; 
        });

cs.controller("AutoreController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page,$window) {
        $scope.Page=Page;
        Page.setTitle("Autore di QR");
    
        $scope.selected=null;
        $scope.argomenti = [];
        $scope.update_ = function (f) {
                $http.get("ArgomentiAutore").then(function(xs){
                        $scope.argomenti=xs.data.result.argomenti;
                        Page.setLogo(xs.data.result.logo);
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

        $scope.deleteArgomento = function(index)  {
                $http.put("DeleteArgomento/" + index).success($scope.update);
                }
        });
cs.controller("VisitatoreController",function ($scope,Page,$http,$window,$location,Page,$modal) {
        $scope.Page = Page;
        Page.setTitle("Visitatore");
        Page.setLogo("static/immagini/logo.png");
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
                $http.put("RemoveFeedback/"+i).success(function (){$scope.update()})}
                });
 

cs.controller("DomandeVisitatoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window,$cookies,$location) {
        $scope.Page = Page;
        $scope.items = [];
        $scope.hash = $routeParams.hash;
        Page.setTitle("Visitatore di QR"); 
        $http.get("ChangeAssoc/"+$scope.hash).success(function(xs){
                $scope.author=xs.result.author;
                $scope.autore=xs.result.autore;
                $scope.items=xs.result.domande;
                $scope.argomento={'text':xs.result.text};
                Page.setLogo (xs.result.logo);
                if(xs.result.nuovo){
                        var modalInstance = $modal.open({
                                animation: true,
                                templateUrl: 'static/firstloging.html',
                                controller: 'Input',
                                size: 'lg',
                                scope:$scope
                                });
                        modalInstance.result.then(
                                function () {},
                                function () {}
                                );
                        }
                        
                });
        $scope.feedback= function (r) {
                $http.put("AddFeedback/"+r).success(function(xs){
                $scope.update();
                        });}
        $scope.update = function () {
                $http.get("ChangeAssoc/"+$scope.hash).success(function(xs){
                        $scope.items=xs.result.domande;
                        });
                        }
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
                        Page.setLogo (xs.result.logo);
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
                $http.post("AddRisposta/"+ i + "/Accettabile" ,"risposta ...").success($scope.update);
                } 
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


