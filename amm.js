

var myApp = angular.module("myApp", ["xeditable",'ui.bootstrap','ngCookies']);

myApp.run(function(editableOptions) {
  editableOptions.theme = 'bs3'; // bootstrap3 theme. Can be also 'bs2', 'default'
});

myApp.controller('Input', function ($scope, $modalInstance) {

          $scope.gotMessage = function () {
            $modalInstance.close();
          };

          $scope.cancel = function () {
            $modalInstance.dismiss('cancel');
          };
        });


myApp.controller("ItemsController",['$scope','$http','$modal','$cookies','$cookieStore','$timeout','$log','$location',function ($scope,$http,$modal,$cookies,$cookieStore,$timeout,$log,$location) {
    $scope.items = [];
    $scope.selected=null;
    $scope.argomenti = [];
    $scope.valori=['Giusta','Sbagliata','Accettabile'];
    $scope.$on('$locationChangeSuccess', function () {
        if($location.path() == "") $scope.selected=null;
    });
    $scope.update = function () {
                $http.get("api/Argomenti").success(function(xs){
                        $scope.argomenti=xs.result;
                $http.get("api/Domande/"+$scope.argomenti[$scope.selected].index).success(function(xs){
                        $scope.items=xs.result;
                        });
                        });
    $scope.input={};
        }
        
   $scope.qr=function(h){
         window.location.href = "api/QR/"+h;
        }

   $scope.update();
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

    $scope.selectArgomento = function (index,h){
        $scope.selected=index;
        $location.url("api/Risorsa/"+h);
        $scope.update();
        }
    $scope.leaveArgomento = function (index){
        $scope.selected=null;
        $scope.update();
        }
    reset = function() {
    $scope.answers=[null,null,null,null];
    $scope.question=null;
        }
    reset();
    $scope.selectedClass = function (index)  {
        if(index==$scope.selected) return "selected"
        return "unselected"
        }
    $scope.changeDomanda = function(value,index)  {
        return $http.post("api/ChangeDomanda/" + index,value);
        }
    $scope.changeArgomento = function(value,index)  {
        return $http.post("api/ChangeArgomento/" + index,value);
        }
    $scope.deleteArgomento = function(index)  {
        $http.put("api/DeleteArgomento/" + index).success($scope.update);
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


