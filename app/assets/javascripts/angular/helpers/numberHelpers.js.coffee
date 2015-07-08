'use strict'

angular.module('helpers')
  .factory('NumberHelper', ()->
    {
      addCommas: (val)->
        val = val.toString()
        decimals = `val.indexOf('.') == -1 ? '' : val.replace(/^-?\d+(?=\.)/, '')`
        wholeNumbers = val.replace /(\.\d+)$/, ''
        commas = wholeNumbers.replace /(\d)(?=(\d{3})+(?!\d))/g, '$1,'
        "#{commas}#{decimals}"
    }
  )
