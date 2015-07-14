@gradecraft.factory 'GradePrototype', ->
  class GradePrototype
    constructor: (attrs={})->
      @id = attrs.id
      @status = attrs.status
      @raw_score = attrs.raw_score
      @feedback = attrs.feedback
      @is_custom_value = attrs.is_custom_value

    toggleCustomValue: ()->
      @is_custom_value = ! @is_custom_value
