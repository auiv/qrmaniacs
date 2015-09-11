
var cs = angular.module("cs", ["xeditable",'ui.bootstrap','ngCookies']);

cs.run(function(editableOptions) {
  editableOptions.theme = 'bs2';
});

cs.factory('Page', function($location,$window,$cookies,$http) {
   var title = 'QR maniacs';
   var logo = "";
   var unlogged=false;
   var id= {}
   update = function () {
          id={};
          id.user=false;
         $http.get("Role").success(function(xs){
                id.user=true;
                id.isAuthor=xs.result.author;
                id.isValidatore=xs.result.validatore;
                id.mail=xs.result.email;
                if(id.mail)id.mailpart=xs.result.email.split("@")[0];
                id.conferma = xs.result.conferma  ;
                id.campagna=xs.result.campagna;
                if(id.isAuthor)
                  $http.get("Validators").success(function(xs){
                          id.validatori=xs.result;
                          });

                });
        }
    update();
   return {
        update : update,
        id : function () {return id},
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
        goBack : function () {$window.history.back()},
        user : function (){return $cookies.get("userName")},
        loginQR : function(){window.location.href = "QR/Login"},
        setUnlogged: function (){unlogged=true},
        unlogged: function(){if(unlogged)window.history.back()}
        };
        });
cs.controller('Input', function ($scope, $modalInstance) {
          $scope.gotMessage = function () {$modalInstance.close();};
          $scope.cancel = function () {$modalInstance.dismiss('cancel');};
          $scope.any = function (x) {$modalInstance.close(x);};
        });

cs.controller("HomeController",function ($scope,Page,$timeout) {
    Page.update();
    Page.setTitle('QR Maniacs');
$timeout(function () { twttr.widgets.load(); }, 500);
    });
cs.controller("RisposteController",function ($scope,Page,$http,$window,$location,$modal) {
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
 


cs.controller("ProfileController",function ($scope,$http,$log,$location,Page,$modal) {
        Page.update();
        $scope.Page = Page;
        Page.setLogo("static/immagini/logo.png");
        $scope.modal={} 
        $scope.checkDelete = function (f,i) {
                $scope.modal.question="Vuoi eliminare tutti i tuoi dati (questionari e risposte)"
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

        $http.get("LoginLink").success(function(xs){
                          $scope.login=xs;
                          });
        $scope.updateMail = function (d) {
                return $http.get("SetMail/" + d).success(function(xs){});
                }
        $scope.esci=function(){
                $http.put("Logout").then(function(xs){$location.url("/");Page.update();});
                }
        $scope.distruggi= function (){
                $scope.checkDelete (function () {
                  $http.put("Destroy").then(function(xs){$location.url("/");Page.update();},function(xs){$location.url("/");Page.update();});
                  });
                }
        });


cs.controller('CampagnaController', function (Page,$scope,$http) {
        $scope.Page=Page;
        $scope.campagna=Page.id().campagna;
        $scope.$watch("campagna.begin",function(a,b) {
                        if(b){
                                $http.post("SetBegin",a,Page.update);
                                }
                        });
        $scope.$watch("campagna.expire",function(a,b) {
                        if(b)$http.post("SetExpire",a,Page.update)});
        $scope.setLogo = function (a) {
                        return $http.post("SetLogo",a,Page.update)};
        $scope.setPlace = function (a) {
                        return $http.post("SetPlace",a,Page.update)};

        Page.setTitle("Campagna");
        });


cs.controller("QuestionariController",function ($scope,$http,Page,$modal,$location) {
        $scope.Page=Page; 
        Page.setTitle("Autore QR");
        Page.setLogo("static/immagini/logo.png");
        $scope.active=false;
        $scope.changeLogo = function (x) {
                return true;
                }
        $scope.confermato = function () {
                return $scope.conferma;
                }

        $scope.selected=null;
        $scope.argomenti = [];
        $scope.update_ = function (f) {
                $http.get("ArgomentiAutore").then(function(xs){
                        $scope.argomenti=xs.data.result.argomenti;
                        f();
                        });
        }
        $scope.update=function(){$scope.update_(function(){})};
        $scope.input={};
        $scope.modal={} 
        $scope.checkDelete = function (f,i) {
                $scope.modal.question="Cancellare il QR  \"" + i + "\""
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

        $scope.deleteArgomento = function(index,text)  {
                $scope.checkDelete(function() {
                  $http.put("DeleteArgomento/" + index).success($scope.update);
                  },text);
                }
        $scope.update();

    });  



cs.controller('LoggedOutController', function (Page) {
        Page.setTitle("Uscito");
        });

cs.controller("title",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page,$route) {
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

cs.controller("AutoreController",function ($scope,$http,$modal,$timeout,$log,$location,$cookies,Page,$window) {
        $scope.Page=Page;
        Page.setTitle("Autore");
    
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

cs.controller("DomandeVisitatoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window,$cookies,$location) {
        $scope.Page = Page;
        $scope.items = [];
        $scope.hash = $routeParams.hash;
        $scope.feedback= function (r,i,z) {
                $http.put("AddFeedback/"+r).success(function(xs){
                for(j=0;j<z.length;j ++)
                  z[j].chosen=false;
                i.chosen=true;
                //$scope.update();
                        });}
        $scope.update = function () {
        $http.get("ChangeAssoc/"+$scope.hash).success(function(xs){
                if(!Page.id().user)Page.update();
                $scope.author=xs.result.author;
                $scope.campagna=xs.result.campagna;
                $scope.items=xs.result.domande;
                $scope.argomento={'text':xs.result.text};
                Page.setTitle($scope.argomento.text); 
                Page.setLogo (xs.result.logo);
                if(xs.result.nuovo){
                        var modalInstance = $modal.open({
                                animation: true,
                                templateUrl: 'static/login.html',
                                controller: 'Input',
                                size: 'lg',
                                scope:$scope
                                });
                        modalInstance.result.then(
                                function () {},
                                function () {$http.put("Destroy").then(function(xs){$location.url("/");});}
                                );
                        }
                        
                $http.get("IsValidate/"+ $scope.hash).success(function(xs){
                        $scope.notValid= !xs.result;
                        });
                });
                        }
        $scope.update();
        });

cs.controller("DomandeAutoreController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
        $scope.Page = Page;
        $scope.items = [];
        $scope.opsoff=false;
        $scope.setOpsoff = function(t) {$scope.opsoff=t;}
        $scope.valori=['Giusta','Sbagliata','Accettabile'];
        $scope.hash = $routeParams.hash;
        $scope.update_ = function (f) {
                $http.get("DomandeAutore/"+$scope.hash).success(function(xs){
                        $scope.items=xs.result.domande;
                        $scope.argomento={'text':xs.result.text};
                        Page.setTitle($scope.argomento.text + "(edit)"); 
                        Page.setLogo (xs.result.logo);
                        f();
                        });
                }
        $scope.update=function(){$scope.update_(function(){})};
        $scope.update();
                
        $scope.input={};
        $scope.modal={};
        $scope.checkDelete = function (f,q) {
                $scope.modal.question=q;
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'static/deleting.html',
                        controller: 'Input',
                        size: 'lg',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {f();},
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
                $scope.checkDelete(function () {
                    $http.put("DeleteDomanda/" + index).success($scope.update);
                    },"Elimina la domanda");
                }
        $scope.deleteRisposta = function(index)  {
                $scope.checkDelete(function () {
                    $http.put("DeleteRisposta/" + index).success($scope.update);
                    },"Elimina la risposta");
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


cs.controller("PromotedController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
Page.setTitle("Promozione");
});
cs.controller("ValidatedController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
Page.setTitle("Validazione");
});
cs.controller("ConfirmedController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
Page.setTitle("Conferma mail");
});
cs.controller("CantPromoteController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
$scope.reason=$routeParams.reason;
Page.setTitle("Promozione");
});
cs.controller("CantValidateController",function ($scope,$http,$modal,$timeout,$log,$routeParams,Page,$window) {
Page.setTitle("Validazione");
$scope.reason=$routeParams.reason;
});
