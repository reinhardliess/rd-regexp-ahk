/*
 * Copyright(c) 2021-2022 Reinhard Liess
 * MIT Licensed
*/

/*
  Class to manage regular expressions
  This class will always use match objects, the flag `O)` will be added automatically.
*/

class rd_RegExp {

  ; -- class variables --

  static ERR_REGEX := "Regular expression error '{1}' in pattern '{2}'"

  ;  throw exceptions by default
  static throwExceptions := true

  /**
  * Constructor
  */
  __New() {
  }

  /**
   * Sets PCRE options
   * @param {string*} options - PCRE options
   *
  */
  setPcreOptions(options*) {
    this._pcreOptions := options ? options.Clone() : []
    return this
  }

  /**
   * Retrieves PCRE options
   * @returns {string[]} options
   *
  */
  getPcreOptions() {
    return this._pcreOptions.Clone()
  }

  /**
   * Processes potential errors
   * Errorlevel holds PCRE error code or message
   * @param {string} regex - RegEx pattern
  */
  _processError(regex) {
    if (rd_RegExp.throwExceptions && ErrorLevel) {
      oldErrorLevel := ErrorLevel
      throw Exception(format(rd_RegExp.ERR_REGEX, oldErrorLevel, this.splitRegex(regex).pattern), -2)
    }
  }
  /**
   * Builds regex pattern: sets "match object" mode, adds PCRE options
   * @param {string} regex - RegEx pattern
   * @returns {string} new RegEx pattern
  */
  _buildRegex(regex) {

    joinedOptions := ""
    for _, option in this._pcreOptions {
      joinedOptions .= option
    }
    split := this.splitRegex(regex)

    return split.flags "O)" joinedOptions split.pattern
  }

  /**
   * Splits RegEx pattern into flags/pattern
   * @param {string} regex - RegEx pattern
   * @returns {object} { flags, pattern }
  */
  splitRegex(regex) {
    ; Group1: flags, group2: pattern
    ; https://regex101.com/r/lFAmkV/1/
    RegExMatch(regex, "O)^(?:([^(]*)\))?(.+)", match)
    return { flags: (match[1]), pattern: (match[2]) }
  }

  /**
   * Match regex, internal
  */
  _match(haystack, regex, startingPos) {
    newRegex := this._buildRegex(regex)
    RegExMatch(haystack, newRegex, result, startingPos)
    this._processError(newRegex)
    return result
  }

  /**
   * Retrieves the result of matching a string against a RegEx
   * @param {string} haystack - text to search
   * @param {string} regex - RegEx pattern
   * @param {integer} [startingPos:=1] - text position to start searching
   * @returns {object | undefined} match object or undefined
  */
  match(haystack, regex, startingPos := 1) {
    return this._match(haystack, regex, startingPos)
  }


  /**
  * For use with Boundfunc: Retrieves the result of matching a string against a RegEx
  * @param {string} regex - RegEx pattern
  * @param {string} haystack - text to search
  * @returns {object | undefined} match object or undefined
  */
  matchB(regex, haystack) {
    return this._match(haystack, regex, 1)
  }

  /**
  * For use with Boundfunc: Retrieves the boolean result of matching a string against a RegEx
  * @param {string} regex - RegEx pattern
  * @param {string} haystack - text to search
  * @returns {boolean} true if match
  */
  isMatchB(regex, haystack) {
    return !!this.matchB(regex, haystack)
  }

  /**
   * retrieves all the results of matching a string against a RegEx
   * @param {string} haystack - text to search
   * @param {string} regex - regex pattern
   * @param {integer} [limit] - maximum number of matches
   * @param {integer} [startingPos:=1] - text position to start searching
   * @returns {Match[]} array of match objects
  */
  matchAll(haystack, regex, limit := -1, startingPos := 1) {
    newRegex := this._buildRegex(regex)

    matches  := []
    Loop {
      RegExMatch(haystack, newRegex, result, startingPos)
      this._processError(newRegex)
      if (!IsObject(result)) {
        break
      }
      matches.Push(result)
      startingPos := result.Pos[0] + result.Len[0]
      if (matches.Length() = limit || startingPos > Strlen(haystack)) {
        break
      }
    }
    return matches
  }

  /**
   * Filters array of match objects by group
   * @param {integer | string} group - group: 0-n or "name"
   * @returns {string[]} requested group as array
  */
  filterAll(matches, group) {

    filtered := []
    for _, match in matches {
      element := match.Value[group]
      filtered.Push(element)
    }
    return filtered
  }


  /**
   * Replace - internal
  */
  _replace(haystack, regex, replacement :="", byRef outputCount:="", limit := -1, startPos := 1) {
    newRegex := this._buildRegex(regex)
    if (!isObject(replacement)) {
      newStr := RegExReplace(haystack, newRegex, replacement, outputCount, limit, startPos)
      this._processError(newRegex)
      return newStr
    }
    ; use callback function
    callback    := replacement
    newStr      := haystack
    outputCount := 0

    Loop {
      if (RegExMatch(newStr, newRegex, match, startPos)) {
        newSubstr := callback.Call(match, haystack)
        newStr    := Substr(newStr, 1, match.Pos[0] - 1) newSubstr Substr(newStr, match.Pos[0] + match.Len[0])
        startPos  := match.Pos[0] + Strlen(newSubstr)
        outputCount += 1
      } else {
        this._processError(newRegex)
        break
      }
      if (outputCount = limit) {
        break
      }
    }

    return newStr
  }

    /**
   * Replaces occurrences of a pattern (regular expression) inside a string
   * @param {string} haystack - string to be searched
   * @param {string} regex - RegEx pattern
   * @param {string | function} replacement - string to be substituted or callback
   * @param {&integer} [outputCount] - number of substitutions
   * @param {integer} [limit=-1] - max number of substitutions
   * @param {integer} [startPos=1] - start position for searching
   * @returns {string} string with substitutions
   *
  */
  replace(haystack, regex, replacement :="", byRef outputCount := "", limit := -1, startPos := 1) {
    return this._replace(haystack, regex, replacement, outputCount, limit, startPos)
  }

  replaceB(regex, replacement, haystack) {
    return this._replace(haystack, regex, replacement)
  }

  /**
   * Escapes RegEx String
   * Adapted from https://github.com/sindresorhus/escape-string-regexp/blob/main/index.js
   * @param {string} string - string to escape
   * @returns {string} escaped string
  */
  escapeString(string) {
    buffer := RegexReplace(string, "[|\\{}()[\]^$+*?.]", "\$0")
    buffer := RegexReplace(buffer, "-", "\$0")
    return buffer
  }
}