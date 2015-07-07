@gradecraft.factory 'AssignmentScoreLevelPrototype', ->
  class AssignmentScoreLevelPrototype
    constructor: (attrs) ->
      @id = attrs.id
      @value= attrs.value
      @name = attrs.name
      @assignment_id = attrs.assignment_id
