@gradecraft.controller 'GradeCtrl', ['$rootScope', '$scope', 'GradePrototype', '$http', 'angular-beforeunload', ($rootScope, $scope, GradePrototype, $http) -> 

  $scope.init = (params)->
    gradeParams = params["grade"]
    $scope.grade = new GradePrototype(gradeParams)
    gradeId = gradeParams.id

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

  window.onbeforeunload = (event, newUrl, oldUrl) ->
    alert("snakes")
    event.preventDefault()
    
    # #Check if there was any change, if no changes, then simply let the user leave
    # if !$scope.grade.hasChanges
    #   return
    # # if $scope.grade.hasChanges
    # message = 'You have unsaved changes that will be saved when you navigate away.'
    # if typeof event == 'undefined'
    #   event = window.event
    # if event
    #   event.returnValue = message
    # message

  GradePrototype = (attrs={})->
    grade = attrs
    this.id = grade["id"]
    this.status = grade["status"]
    this.raw_score = grade["raw_score"]
    this.feedback = grade["feedback"]

    # manage object state
    this.hasChanges = false
    this.locationHandler = null

  GradePrototype.prototype = 
    change: ()->
      this.addLocationHandler() unless this.hasChanges
      this.hasChanges = true

    addLocationHandler: ()->
    #   $scope.$on('$locationChangeStart', (event, next, current)->
    #     if(!confirm("Are you sure you want to leave this page?"))
    #       event.preventDefault()
    #   )
      
    update: ()->
      if this.hasChanges
        self = this
        $http.put("/grades/#{self.id}/async_update", self).success(
          (data,status)->
            self.resetChanges()
        )
        .error((err)->
        )

    unloadUpdate: ()->
      self = this
      $http.put("/grades/#{self.id}/async_update", self).success(
        (data,status)->
          self.resetChanges()
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
    resetChanges: ()->
      this.hasChanges = false

]
