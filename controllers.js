
var controllers = angular.module("controllers", ["xeditable",'ui.bootstrap']);

controllers.controller('Input', function ($scope, $modalInstance) {

          $scope.gotMessage = function () {
            $modalInstance.close();
          };

          $scope.cancel = function () {
            $modalInstance.dismiss('cancel');
          };
        });

controllers.controller("ArgomentiController",['$scope','$http','$modal','$timeout','$log','$location',function ($scope,$http,$modal,$timeout,$log,$location) {
    $scope.selected=null;
    $scope.argomenti = [];
    $scope.update = function () {
                $http.get("api/Argomenti").then(function(xs){
                        alert(1);     
                        $scope.argomenti=xs.result;
                        },function(x) {alert(x.statusText)});
        }
   $scope.update();
   $scope.input={};
   $scope.qr=function(h){
         window.location.href = "api/QR/"+h;
        }

     $scope.checkDelete = function (f,i) {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'deleting.html',
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
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'argomento.html',
                        controller: 'Input',
                        size: 'lg',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {
                                $http.post("api/AddArgomento",$scope.input.argomento).success($scope.update);}, 
                        function () {}
                        );
                };

    $scope.selectedClass = function (index)  {
        if(index==$scope.selected) return "selected"
        return "unselected"
        }
    $scope.changeArgomento = function(value,index)  {
        return $http.post("api/ChangeArgomento/" + index,value);
        }
    $scope.deleteArgomento = function(index)  {
        $http.put("api/DeleteArgomento/" + index).success($scope.update);
        }
}]);


controllers.controller("DomandeController",['$scope','$http','$modal','$timeout','$log','$routeParams',function ($scope,$http,$modal,$timeout,$log,$routeParams) {
    $scope.items = [];
    $scope.valori=['Giusta','Sbagliata','Accettabile'];
    $scope.hash = $routeParams.hash;
    $scope.update = function () {
                $http.get("api/Domande/"+$scope.hash).success(function(xs){
                        $scope.items=xs.result.domande;
                        $scope.argomento=xs.result.text;
                        });
                }
   $scope.update();
                
   $scope.input={};

     $scope.checkDelete = function (f,i) {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'deleting.html',
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
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'domanda.html',
                        controller: 'Input',
                        size: 'sm',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {
                                $http.post("api/AddDomanda/"+ i,$scope.input.domanda).success($scope.update);}, 
                        function () {}
                        );
                };    
      $scope.addRisposta = function (i) {
                var modalInstance = $modal.open({
                        animation: true,
                        templateUrl: 'risposta.html',
                        controller: 'Input',
                        size: 'sm',
                        scope:$scope
                        });
                modalInstance.result.then(
                        function () {
                                $http.post("api/AddRisposta/"+ i + "/" + $scope.input.value,$scope.input.risposta).success($scope.update);}, 
                        function () {}
                        );
                };

    $scope.changeDomanda = function(value,index)  {
        return $http.post("api/ChangeDomanda/" + index,value);
        }
    $scope.deleteDomanda = function(index)  {
        $http.put("api/DeleteDomanda/" + index).success($scope.update);
        }
    $scope.deleteRisposta = function(index)  {
        $http.put("api/DeleteRisposta/" + index).success($scope.update);
        }
    
    $scope.changeRisposta = function(value,index)  {
        return $http.post("api/ChangeRisposta/" + index,value);
        }
    $scope.changeRispostaValue = function(value,index)  {
        return $http.put("api/ChangeRispostaValue/" + index + "/" + value);
        }
}]);


