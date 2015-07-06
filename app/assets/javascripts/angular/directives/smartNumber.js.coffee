NumberModule = angular.module('smart-number', [])

NumberModule.directive 'smartNumber',
['smartNumberConfig', (smartNumberConfig) ->

    defaultOptions = smartNumberConfig.defaultOptions

    # 0 = tab, 8 = backspace , 13 = enter, 46 = delete, 37 = left arrow, 39 = right arrow, 65 = A
    controlKeys = [0,8,13, 46, 37, 39, 65] 

    # 37 = left arrow, 39 = right arrow, 9 = enter, 33 = page up, 34 = page down
    inertKeys = [37, 39, 9, 33, 34]

    keyCodes = { 48:0, 49:1, 50:2, 51:3, 52:4, 53:5, 54:6, 55:7, 56:8, 57:9 }

    numberCharacterPressed = (keycode)->
      keycode >= 48 and keycode <= 57 # insert number character

    # Ctrl key helpers
    initCtrlKeys = (scope)->
      scope.ctrlDownCount = 0

    isCtrl = (event) ->
      event.which == 17

    ctrlDownCount = (scope)->
      scope.ctrlDownCount

    ctrlActive = (scope)->
      scope.ctrlDownCount > 0

    registerCtrl = (scope)->
      if scope.ctrlDownCount <= 1
        scope.ctrlDownCount += 1
      else
        scope.ctrlDownCount = 2

    unregisterCtrl = (scope)->
      # ctrlDownCount should never be less than zero
      if scope.ctrlDownCount > 0
        scope.ctrlDownCount -= 1
      else
        scope.ctrlDownCount = 0

    # key recognition helpers
    isDelete = (event)->
      event.which == 46

    isBackspace = (event)->
      event.which == 8

    isLetterA = (event)->
      event.which == 65

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

    isInertKey = (which) ->
      inertKeys.indexOf(which) >= 0

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

    triggerChange = (elem) ->
      elem.trigger("change")

    # helper methods for finding the new cursor position based on input type
    findNewCharacterCursorPosition = (elem, initialPosition) ->
      if elem.val().length == 3 || elem.val().length == 7 # a new comma will be added
        initialPosition + 2
      else if elem[0].selectionStart < elem.val().length # cursor is adding numbers, but is not at the end of the input field
        initialPosition + 1
      else # cursor is adding numbers at the end of the input field
        initialPosition + 1

    findNewDeleteCursorPosition = (elem, initialPosition) ->
      if elem.val().length == 5 || elem.val().length == 9 # a comma will be removed
        if commaAfterCursor(elem)
          return initialPosition
        else
          return initialPosition - 1
      else # cursor is adding numbers at the end of the input field
        if commaAfterCursor(elem)
          return initialPosition + 1
        else
          return initialPosition

    findNewBackspaceCursorPosition = (elem, initialPosition) ->
      if elem.val().length == 5 || elem.val().length == 9 # a comma will be removed
        return initialPosition - 2
      else # cursor is adding numbers at the end of the input field
        if commaBeforeCursor(elem)
          return initialPosition - 2
        else
          return initialPosition - 1

    commaAfterCursor = (elem) ->
      cursorPos = elem[0].selectionStart
      elem.val().charAt(cursorPos) == ","

    commaBeforeCursor = (elem) ->
      cursorPos = elem[0].selectionStart - 1
      elem.val().charAt(cursorPos) == ","

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
      if commaBeforeCursor(elem)
        newValue = [originalValue.slice(0, position - 2), originalValue.slice(position)].join('') # insert the new number into the field
      else
        newValue = [originalValue.slice(0, position - 1), originalValue.slice(position)].join('') # insert the new number into the field
      elem.val(newValue) # replace the original value with the new one

    # handle delete keypresses
    deletePressed = (elem, event) ->
      originalValue = elem.val() # the original value of the field before keypress
      position = elem[0].selectionStart # cursor position
      if commaAfterCursor(elem)
        newValue = [originalValue.slice(0, position), originalValue.slice(position + 2)].join('') # insert the new number into the field
      else
        newValue = [originalValue.slice(0, position), originalValue.slice(position + 1)].join('') # insert the new number into the field

      elem.val(newValue) # replace the original value with the new one

    deleteSelectedRange = (elem, event) ->
      originalValue = elem.val() # the original value of the field before keypress
      startPosition = elem[0].selectionStart # beginning of selected range
      endPosition = elem[0].selectionEnd # end of selected range
      newValue = [originalValue.slice(0, startPosition), originalValue.slice(endPosition)].join('') # insert the new number into the field
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

    {
        restrict: 'A'
        require: 'ngModel'
        scope: {
        }
        link: (scope, elem, attrs, ngModelCtrl) ->
            options = getOptions scope, attrs
            isValid = makeIsValid options
            reformatRequired = false
            scope.ctrlDownCount = 0

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
              # record that a ctrl key has been released
              unregisterCtrl(scope) if isCtrl(event)

              return if invalidInput(elem, event)

            elem.on 'blur', ->
              scope.ctrlDownCount = 0

            elem.on 'focus', ->
              scope.ctrlDownCount = 0

            elem.on 'keydown', (event) ->
              keycode = event.which

              # allow normal functionality if the key doesn't interfere with input
              killEvent(event) unless isInertKey(keycode)

              # indicate that a ctrl key has been pressed
              registerCtrl(scope) if isCtrl(event)

              # do nothing if the key pressed isn't a permissable operation
              return if invalidInput(elem, event)
              
              # find the cursor position
              initialPosition = elem[0].selectionStart 


              # do different stuff if ctrl is pressed
              if scope.ctrlDownCount > 0

                if isDelete(event)
                  # get the string before the selection and figure out how many commas it has
                  originalCursorPosition = elem[0].selectionStart
                  stringBeforeCursor = elem.val().slice(0, originalCursorPosition)
                  elem.val resetCommas(stringBeforeCursor) # reformat the number in place

                  # set the final cursor position
                  finalCursorPosition = elem.val().length
                  elem[0].setSelectionRange(finalCursorPosition, finalCursorPosition) # set the new cursor position

                  # trigger final change event
                  triggerChange(elem)

                if isBackspace(event)
                  # get the string before the selection and figure out how many commas it has
                  originalCursorPosition = elem[0].selectionEnd
                  stringAfterCursor = elem.val().slice(originalCursorPosition, elem.val().length)
                  elem.val resetCommas(stringAfterCursor) # reformat the number in place

                  # set the final cursor position
                  elem[0].setSelectionRange(1,1) # set the cursor at the beginning of the input field

                  # trigger final change event
                  triggerChange(elem)

                if event.which == 65
                  elem[0].setSelectionRange(0, elem.val().length) # highlight the entire field

              else

                if numberCharacterPressed(keycode)
                  unless maxDigitsReached(elem, 9)
                    newCursorPosition = findNewCharacterCursorPosition(elem, initialPosition)
                    insertCharacter(elem, event)
                    elem.val resetCommas(elem.val()) # reformat the number in place
                    elem[0].setSelectionRange(newCursorPosition, newCursorPosition) # set the new cursor position
                    triggerChange(elem)

                if isBackspace(event) # backspace is pressed

                  if elem[0].selectionEnd > elem[0].selectionStart # text is highlighted
                    # get the string before the selection and figure out how many commas it has
                    originalCursorPosition = elem[0].selectionStart
                    stringBeforeCursor = elem.val().slice(0, originalCursorPosition)
                    startingCommasBeforeCursor = (stringBeforeCursor.match(/,/g) || []).length

                    # delete the selected stuff and reset the commas
                    deleteSelectedRange(elem, event)
                    elem.val resetCommas(elem.val()) # reformat the number in place

                    # figure out how many commas were lost
                    finalStringBeforeCursor = elem.val().slice(0, originalCursorPosition)
                    endingCommasBeforeCursor = (finalStringBeforeCursor.match(/,/g) || []).length
                    commaDiff = startingCommasBeforeCursor - endingCommasBeforeCursor

                    # set the final cursor position
                    finalCursorPosition = originalCursorPosition - commaDiff
                    elem[0].setSelectionRange(finalCursorPosition, finalCursorPosition) # set the new cursor position

                    # trigger final change event
                    triggerChange(elem)

                  else unless elem[0].selectionStart == 0 # do nothing if it's at the end of the end of the input
                    newCursorPosition = findNewBackspaceCursorPosition(elem, initialPosition)
                    backspacePressed(elem, event) # handle logic for backspace
                    elem.val resetCommas(elem.val()) # reformat the number in place
                    elem[0].setSelectionRange(newCursorPosition, newCursorPosition) # set the new cursor position

                    # trigger final change event
                    triggerChange(elem)
                
                if isDelete(event) # delete is pressed
                  if elem[0].selectionEnd > elem[0].selectionStart # text is highlighted
                    # get the string before the selection and figure out how many commas it has
                    originalCursorPosition = elem[0].selectionStart
                    stringBeforeCursor = elem.val().slice(0, originalCursorPosition)
                    startingCommasBeforeCursor = (stringBeforeCursor.match(/,/g) || []).length

                    # delete the selected stuff and reset the commas
                    deleteSelectedRange(elem, event)
                    elem.val resetCommas(elem.val()) # reformat the number in place

                    # figure out how many commas were lost
                    finalStringBeforeCursor = elem.val().slice(0, originalCursorPosition)
                    endingCommasBeforeCursor = (finalStringBeforeCursor.match(/,/g) || []).length
                    commaDiff = startingCommasBeforeCursor - endingCommasBeforeCursor

                    # set the final cursor position
                    finalCursorPosition = originalCursorPosition - commaDiff
                    elem[0].setSelectionRange(finalCursorPosition, finalCursorPosition) # set the new cursor position

                    # trigger final change event
                    triggerChange(elem)

                  else unless elem[0].selectionStart == elem.val().length
                    newCursorPosition = findNewDeleteCursorPosition(elem, initialPosition)
                    deletePressed(elem, event) # handle logic for backspace
                    elem.val resetCommas(elem.val()) # reformat the number in place
                    elem[0].setSelectionRange(newCursorPosition, newCursorPosition) # set the new cursor position

                    # trigger final change event
                    triggerChange(elem)
              
            elem.on 'keypress', (event) ->
              killEvent(event)

    }
]

NumberModule.provider 'smartNumberConfig', ->
  _defaultOptions = {}

  @setDefaultOptions = (defaultOptions) ->
    _defaultOptions = defaultOptions

  @$get = ->
    defaultOptions: _defaultOptions

  return
