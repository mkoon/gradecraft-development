# All directives used on the predictor page.

# Article Icon
# Defines hovertext and font awesome icons for the icon bar in the predictor.
# Each icon is turned on by by a boolean on the assignment or badge model with the same name.
# Icons are defined in the predictor service and looped through in the haml:
# "is_required", "is_late", "has_info", "is_locked", "has_been_unlocked", "is_a_condition", "group"

@gradecraft.directive 'predictorArticleIcon', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      iconName: '='
      target: '='
      targetType: '@'
    }
    templateUrl: 'ng_predictor_icons.html'
    link: (scope, el, attr)->

      scope.targetTerm = ()->
        if @targetType == "assignment"
          PredictorService.termFor.assignment
        else if @targetType == "badge"
          PredictorService.termFor.badge
        else
          "item"

      scope.description = ()->
        if @target.description
          if @target.description.length > 255
            return @target.description.substring(0,255) + "..."
          else
            return @target.description
        else
          return ""

      scope.conditions = ()->
        @target.unlock_conditions

      scope.keys = ()->
        @target.unlock_keys

      scope.iconHtml = {
        is_late: {
          tooltip: 'This ' + scope.targetTerm() + ' is late!'
          icon: "fa-exclamation-triangle"
        }
        has_closed: {
          tooltip: 'This ' + scope.targetTerm() + ' is no longer open for submissions'
          icon: "fa-ban"
        }
        is_required: {
          tooltip: 'This ' + scope.targetTerm() + ' is required!'
          icon: "fa-star"
        }
        has_info: {
          tooltip: scope.description()
          icon: "fa-info-circle"
        }
        has_rubric: {
          tooltip: 'This ' + scope.targetTerm() + ' is rubric graded'
          icon: "fa-th"
        }
        accepts_submissions: {
          tooltip: 'This ' + scope.targetTerm() + ' accepts submissions'
          icon: "fa-paperclip"
        }
        is_locked: {
          tooltip: scope.conditions()
          icon: "fa-lock"
        }
        is_unlocked: {
          tooltip: scope.conditions()
          icon: "fa-unlock-alt"
        }
        is_a_condition: {
          tooltip: scope.keys()
          icon: "fa-key"
        }
        is_earned_by_group: {
          tooltip: 'This ' + scope.targetTerm() + ' is earned by a group'
          icon: "fa-cubes"
        }
      }
  }
]

@gradecraft.directive 'predictorBinarySwitch', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
      targetType: '@'
      onValue: '='
      offValue: '='
    }
    templateUrl: 'ng_predictor_switch.html'
    link: (scope, el, attr)->
      scope.switchState = ()->
        if @targetType == 'assignment'
          if @target.grade.predicted_score == @offValue then 'off' else 'on'
        else if @targetType == 'badge'
          if @target.prediction.times_earned == 0 then 'off' else 'on'

      scope.textForSwitch = ()->
        if @targetType == 'assignment'
          if @target.pass_fail
            if @target.grade.predicted_score == @offValue then PredictorService.termFor["fail"] else PredictorService.termFor["pass"]
          else
            if @target.grade.predicted_score == @offValue then @offValue else @onValue
        else if @targetType == 'badge'
          if @target.prediction.times_earned == 0 then @offValue else @onValue

      scope.toggleSwitch = ()->
        if @targetType == 'assignment'
          @target.grade.predicted_score = if @target.grade.predicted_score == @offValue then @onValue else @offValue
          PredictorService.postPredictedGrade(@target.id,@target.grade.predicted_score)
        else if @targetType == 'badge'
          @target.prediction.times_earned = if @target.prediction.times_earned == 0 then 1 else 0
          PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
  }
]

@gradecraft.directive 'predictorCounterSwitch', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'ng_predictor_counter.html'
    link: (scope, el, attr)->
      scope.atMin = ()->
        @target.prediction.times_earned <= @target.earned_badge_count
      scope.increment = ()->
        @target.prediction.times_earned += 1
        PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
      scope.decrement = ()->
        if scope.atMin()
          return false
        else
          @target.prediction.times_earned -= 1
          PredictorService.postPredictedBadge(@target.id,@target.prediction.times_earned)
  }
]

@gradecraft.directive 'predictorAssignmentTypeWeights', [ 'PredictorService', (PredictorService)->

  return {
    restrict: 'C'
    scope: {
      target: '='
    }
    templateUrl: 'ng_predictor_weights.html'
    link: (scope, el, attr)->
      scope.increment = ()->
        @target.student_weight += 1
        PredictorService.postAssignmentTypeWeight(@target.id,@target.student_weight)
      scope.decrement = ()->
        @target.student_weight -= 1
        PredictorService.postAssignmentTypeWeight(@target.id,@target.student_weight)
      scope.unusedWeights = ()->
        _.range(PredictorService.weights.unusedWeights())
      scope.usedWeights = ()->
        _.range(@target.student_weight)
      scope.weightsAvailable = ()->
        if @target.student_weight < 1
          return false if PredictorService.weights.unusedTypes() < 1
        if PredictorService.weights.max_weights
          @target.student_weight < PredictorService.weights.max_weights && PredictorService.weights.unusedWeights() > 0
        else
          PredictorService.weights.unusedWeights() > 0
      scope.hasWeights = ()->
        @target.student_weight > 0
      scope.weightsOpen = ()->
        PredictorService.weights.open
      scope.defaultMultiplier = ()->
        PredictorService.weights.default_weight
  }
]
