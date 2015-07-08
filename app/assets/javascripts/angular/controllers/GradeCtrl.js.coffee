@gradecraft.controller 'GradeCtrl', ['$rootScope', '$scope', 'GradePrototype', 'AssignmentScoreLevelPrototype', '$window', '$http', ($rootScope, $scope, GradePrototype, AssignmentScoreLevelPrototype, $window, $http) -> 

  $scope.init = (grade, assignmentScoreLevels)->
    $scope.header = "waffles" 
    gradeParams = grade["grade"]
    $scope.grade = new GradePrototype(gradeParams)

    gradeId = gradeParams.id
    $scope.rawScoreUpdating = false
    $scope.hasChanges = false
    $scope.gradeStatuses = ["In Progress", "Graded", "Released"]

    $scope.assignmentScoreLevels = []
    $scope.addAssignmentScoreLevels = (assignmentScoreLevels)->
      angular.forEach(assignmentScoreLevels, (scoreLevel, index)->
        scoreLevelPrototype = new AssignmentScoreLevelPrototype(scoreLevel, $scope)
        $scope.assignmentScoreLevels.push scoreLevelPrototype
      )

    $scope.addAssignmentScoreLevels(assignmentScoreLevels)

    $scope.froalaOptions = {
      inlineMode: false,
      minHeight: 100,
      buttons: [ "bold", "italic", "underline", "strikeThrough", "subscript", "superscript", "fontFamily", "fontSize", "color", "formatBlock", "blockStyle", "inlineStyle", "align", "insertOrderedList", "insertUnorderedList", "outdent", "indent", "selectAll", "createLink", "insertVideo", "table", "undo", "redo", "html", "save", "insertHorizontalRule", "removeFormat" ],

      #Set the save URL.
      saveURL: '/grades/' + gradeId + '/async_update',

      #HTTP request type.
      saveRequestType: 'PUT',

      # Additional save params.
      saveParams: {"save_type": "feedback"}
    }

  GradePrototype = (attrs={})->
    grade = attrs
    this.id = grade["id"]
    this.status = grade["status"]
    this.raw_score = grade["raw_score"]
    this.feedback = grade["feedback"]

  GradePrototype.prototype = {
    modelOptions: ()->
      {
        updateOn: 'default blur',
        debounce: {
          default: 1800,
          blur: 0
        }
      }

    update: ()->
      self = this
      $http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
      )
      .error((err)->
      )

    params: ()->
      {
        id: self.id,
        status: self.status,
        raw_score: this.raw_score,
        feedback: this.feedback
      }

  }

]
