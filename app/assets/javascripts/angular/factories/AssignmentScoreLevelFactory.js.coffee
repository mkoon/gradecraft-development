@gradecraft.factory 'AssignmentScoreLevelPrototype', ['NumberHelper', (NumberHelper)->
  class AssignmentScoreLevelPrototype

    constructor: (attrs) ->
      @id = attrs.id
      @value= attrs.value
      @formatted_value = null
      @name = attrs.name
      @assignment_id = attrs.assignment_id
      this.cacheFormattedValue()

    cacheFormattedValue: ()->
      @formatted_value = NumberHelper.addCommas(@value)

]
