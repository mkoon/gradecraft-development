@gradecraft.controller 'GradeSchemeElementsCtrl', ['$scope', '$http', 'GradeSchemeElementsService', ($scope, $http, GradeSchemeElementsService) ->
  GradeSchemeElementsService.getGradeSchemeElements().success (response)->
    $scope.generateInputs(response.grade_scheme_elements)
    # debugger

  $scope.gse = @
  $scope.gse.model = {}
  $scope.gse.fields = []

  $scope.generateInputs = (elements) ->
    fields = []
    angular.forEach elements, (element)->
      tmp = {}
      tmp.type = 'input'
      tmp.templateOptions = {}
      tmp.templateOptions.label = element.letter
      fields.push tmp
    $scope.gse.fields = fields
  return
]
