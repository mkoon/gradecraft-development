NumberModule = angular.module('smart-number', [])

NumberModule.directive 'smartNumber',
['smartNumberConfig', (smartNumberConfig) ->

    defaultOptions = smartNumberConfig.defaultOptions

    # 0 = tab, 8 = backspace , 13 = enter, 46 = delete, 37 = left arrow, 39 = right arrow
    controlKeys = [0,8,13, 46, 37, 39] 
    keyCodes = { 48:0, 49:1, 50:2, 51:3, 52:4, 53:5, 54:6, 55:7, 56:8, 57:9 }

    getOptions = (scope, attrs) ->
        options = angular.copy defaultOptions
        if attrs.smartNumberOptions?
            for own option, value of scope.$eval(attrs.smartNumberOptions)
                options[option] = value
        options
    
    isNumber = (val) ->
        !isNaN(parseFloat(val)) && isFinite(val)

    # 44 is ',', 45 is '-', 57 is '9' and 47 is '/'
    isNotDigit = (which) ->
        (which < 44 || which > 57 || which is 47)

    isTooLong = (val, maxDigits) ->
      val >= maxDigits

    isMovementKey = (e) ->
      e.which == 37 || e.which == 39

    isDigit = (which) ->
      (which >= 44 and which <= 57 and which is not 47)

    isNotControlKey = (which) ->
      controlKeys.indexOf(which) == -1

    isControlKey = (which) ->
      controlKeys.indexOf(which) >= 0

    invalidInput = (elem, event) ->
      invalidKey(event) or invalidZero(elem, event)

    # invalid actions
    invalidKey = (event) ->
      isNotDigit(event.which) && isNotControlKey(event.which)

    invalidZero = (elem, event) ->
      # entering 0 in the first place
      elem[0].selectionStart == 0 and event.which == 48 

    maxDigitsReached = (elem, maxDigits) ->
      elem.val().length >= maxDigits

    hasMultipleDecimals = (val) ->
      val? && val.toString().split('.').length > 2

    makeMaxDecimals = (maxDecimals) ->
        if maxDecimals > 0
            regexString = "^-?\\d*\\.?\\d{0,#{maxDecimals}}$"
        else
            regexString = "^-?\\d*$"
        validRegex = new RegExp regexString

        (val) -> validRegex.test val
        
    makeMaxNumber = (maxNumber) ->
        (val, number) -> number <= maxNumber

    makeMinNumber = (minNumber) ->
        (val, number) -> number >= minNumber

    makeMaxDigits = (maxDigits) ->
        validRegex = new RegExp "^-?\\d{0,#{maxDigits}}(\\.\\d*)?$"
        (val) -> validRegex.test val

    killEvent = (event) ->
      event.preventDefault()
      event.stopPropagation()

    findNewCharacterCursorPosition = (elem, initialPosition) ->
      if elem.val().length == 4 || elem.val().length == 8 # a new comma is added
        initialPosition + 1
      else if elem[0].selectionStart < elem.val().length # cursor is adding numbers, but is not at the end of the input field
        initialPosition
      else # cursor is adding numbers at the end of the input field
        initialPosition + 1

    findNewDeleteCursorPosition = (elem, initialPosition) ->
      initialPosition

    findNewBackspaceCursorPosition = (elem, initialPosition) ->
      if elem.val().length == 3 || elem.val().length == 7 # a comma has been removed
        return initialPosition - 1
      else # cursor is adding numbers at the end of the input field
        return initialPosition

    backspaceAtComma = (elem, event) ->
      cursorPos = elem[0].selectionStart
      elem.val().charAt(elem[0].selectionStart - 1) == "," and event.which == 8
    
    deleteAtComma = (elem, event) ->
      cursorPos = elem[0].selectionStart
      elem.val().charAt(cursorPos) == "," and event.which == 46

    moveCursorLeft = (elem) ->
      newCursorPos = elem[0].selectionStart - 1
      elem[0].setSelectionRange(newCursorPos, newCursorPos)

    moveCursorRight = (elem) ->
      newCursorPos = elem[0].selectionStart + 1
      elem[0].setSelectionRange(newCursorPos, newCursorPos)

    # logic for handling insertion of number characters
    insertCharacter = (elem, event) ->
      character = keyCodes[event.which] # which character was entered
      originalValue = elem.val() # the original value of the field before keypress
      position = elem[0].selectionStart # cursor position
      newValue = [originalValue.slice(0, position), character, originalValue.slice(position)].join('') # insert the new number into the field
      elem.val(newValue) # replace the original value with the new one

    # handle backspace keypresses
    backspacePressed = (elem, event) ->
      originalValue = elem.val() # the original value of the field before keypress
      position = elem[0].selectionStart # cursor position
      newValue = [originalValue.slice(0, position - 1), originalValue.slice(position)].join('') # insert the new number into the field
      elem.val(newValue) # replace the original value with the new one

    # handle backspace keypresses
    deletePressed = (elem, event) ->
      originalValue = elem.val() # the original value of the field before keypress
      position = elem[0].selectionStart # cursor position
      newValue = [originalValue.slice(0, position), originalValue.slice(position + 1)].join('') # insert the new number into the field
      elem.val(newValue) # replace the original value with the new one

    makeIsValid = (options) ->
        validations = []
        
        if options.maxDecimals?
            validations.push makeMaxDecimals options.maxDecimals
        if options.max?
            validations.push makeMaxNumber options.max
        if options.min?
            validations.push makeMinNumber options.min
        if options.maxDigits?
            validations.push makeMaxDigits options.maxDigits
            
        (val) ->
            return false unless isNumber val
            return false if hasMultipleDecimals val
            number = Number val
            for i in [0...validations.length]
                return false unless validations[i] val, number
            true
        
    addCommasToInteger = (val) ->
        decimals = `val.indexOf('.') == -1 ? '' : val.replace(/^-?\d+(?=\.)/, '')`
        wholeNumbers = val.replace /(\.\d+)$/, ''
        commas = wholeNumbers.replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'
        "#{commas}#{decimals}"

    numberWithCommas = (integer) ->
      integer.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

    resetCommas = (val) ->
      stripped = val.replace(/,/g, "")
      numberWithCommas(stripped)

    # update handling
    triggerUpdate = (scope, elem) ->
      if scope.grade.raw_score != elem.val()
        scope.grade.customUpdate(elem.val())
      scope.rawScoreUpdating = false

    beginUpdate = (scope, elem)->
      scope.rawScoreUpdating = true
      setTimeout(triggerUpdate(scope, elem), 1400)

    {
        restrict: 'A'
        require: 'ngModel'
        scope:
          true
        link: (scope, elem, attrs, ngModelCtrl) ->
            options = getOptions scope, attrs
            isValid = makeIsValid options
            reformatRequired = false

            ngModelCtrl.$parsers.unshift (viewVal) ->
                noCommasVal = viewVal.replace /,/g, ''
                if isValid(noCommasVal) || !noCommasVal
                    ngModelCtrl.$setValidity 'Number', true
                    return noCommasVal
                else
                    ngModelCtrl.$setValidity 'Number', false
                    return undefined

            ngModelCtrl.$formatters.push (val) ->
                if options.nullDisplay? && (!val || val == '')
                    return options.nullDisplay
                return val if !val? || !isValid val
                ngModelCtrl.$setValidity 'Number', true
                val = addCommasToInteger val.toString()
                if options.prepend?
                  val = "#{options.prepend}#{val}"
                if options.append?
                  val = "#{val}#{options.append}"
                val

            elem.on 'keyup', (event) ->

              return if invalidInput(elem, event)

              # not updating unless value is longer than 4 digits including commas
              # still some issues moving the comma after input/delete
              # need to add support for delete/backspace if comma is present
              # issue where formatting is not occurring when entered too quickly
              if scope.rawScoreUpdating == false
                beginUpdate(scope, elem)

            elem.on 'blur', ->
                viewValue = ngModelCtrl.$modelValue
                return if !viewValue? || !isValid(viewValue)
                for formatter in ngModelCtrl.$formatters
                    viewValue = formatter(viewValue)
                ngModelCtrl.$viewValue = viewValue
                ngModelCtrl.$render()

            elem.on 'focus', ->
                val = elem.val()
                if options.prepend?
                  val = val.replace options.prepend, ''
                if options.append?
                  val = val.replace options.append, ''
                # elem.val val.replace /,/g, '' # ATTN: LINE THAT ADDS ON-CLICK COMMA REMOVAL
                elem[0].select()

            elem.on 'keydown', (event) ->
              keycode = event.which
              killEvent(event) unless keycode == 37 || keycode == 39 # kill the standard event

              return if invalidInput(elem, event)
              # unless isControlKey(keycode)
                # return if maxDigitsReached(event, 9) 
              
              initialPosition = elem[0].selectionStart 

              if keycode >= 48 and keycode <= 57 # insert number character
                insertCharacter(elem, event)
                elem.val resetCommas(elem.val()) # reformat the number in place
                newCursorPosition = findNewCharacterCursorPosition(elem, initialPosition)

              if keycode == 8 # backspace is pressed
                backspacePressed(elem, event) # handle logic for backspace
                elem.val resetCommas(elem.val()) # reformat the number in place
                newCursorPosition = findNewBackspaceCursorPosition(elem, initialPosition)
              
              if keycode == 46 # backspace is pressed
                deletePressed(elem, event) # handle logic for backspace
                elem.val resetCommas(elem.val()) # reformat the number in place
                newCursorPosition = findNewDeleteCursorPosition(elem, initialPosition)

              elem[0].setSelectionRange(newCursorPosition, newCursorPosition) # set the new cursor position
              
            elem.on 'keypress', (event) ->
              killEvent(event)

              if keycode == 8 # backspace is pressed
                alert("snakes!")

    }
]

NumberModule.provider 'smartNumberConfig', ->
  _defaultOptions = {}

  @setDefaultOptions = (defaultOptions) ->
    _defaultOptions = defaultOptions

  @$get = ->
    defaultOptions: _defaultOptions

  return
