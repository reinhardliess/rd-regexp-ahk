 ; cspell:disable
#NoEnv
; #SingleInstance force
#Warn All, OutputDebug
; #Warn, UseUnsetLocal, Off
#NoTrayIcon

SetWorkingDir, %A_ScriptDir%

#Include, %A_ScriptDir%\..\rd_RegExp.ahk
#Include, %A_ScriptDir%\..\node_modules\unit-testing.ahk\export.ahk

; set defaults
StringCaseSense Locale

; for timings
SetBatchLines, -1

global assert := new unittesting()

OnError("ShowError")

; -Tests --

assert.group("RegExp Class")
test_regex()

; -End of tests --

assert.fullReport()
assert.writeTestResultsToFile()

ExitApp, % assert.failTotal

; -- IniFile Class --

; -- RexExp Class --

test_regex() {

  assert.label("RegEx options/flags")
  R     := new rd_RegExp()
  RxOpt := new rd_RegExp().setPcreOptions("(*ANYCRLF)", "(*UCP)")

  assert.label("RegEx - escape string")
  assert.test(R.escapeString("iste [sit]-amet"),"iste \[sit\]\-amet")

  assert.label("RegEX - split RegEx pattern")
  assert.test(R.splitRegex("im)test"), {flags: "im", pattern: "test"})
  assert.test(R.splitRegex("test"), {flags: "", pattern: "test"})

  assert.label("RegEx - build RegEx pattern")
  assert.test(RxOpt._buildRegex("im)^abc$"), "imO)(*ANYCRLF)(*UCP)^abc$")

  assert.label("RegEx match")
  match := R.match("test hello`nTest25", "m`n)^Test\d+")
  assert.test(match[0], "Test25")

  assert.label("RegEx matchall")
  matches := R.matchAll("test1 hello`nTest25", "im`n)^not-found\d+")
  assert.test(R.filterAll(matches, 0), "")

  matches := R.matchAll("The quick brown fox jumps over the lazy dog.","i)(The) (\w+)\b")
  assert.test(R.filterAll(matches, 2), ["quick", "lazy"])

  matches := R.matchAll("The quick brown fox jumps over the lazy dog.","i)(The) (?P<word>\w+)\b")
  assert.test(R.filterAll(matches, "word"), ["quick", "lazy"])

  assert.label("RegEx replace")
  newStr := R.replace("abcXYZ123", "abc(.*)123", "aaa$1zzz")
  assert.test(newStr, "aaaXYZzzz")

  assert.label("RegEx replace with callback")
  newStr := R.replace("abcabc", "a", func("fn_Rx1"), replaceCount)
  obj := { newStr: (newStr), replaceCount: (replaceCount)}
  assert.test(obj, {newStr: "abc$bc", replaceCount: 2})

  newStr := R.replace("Lara Croft", "(?<firstname>\w+) (?<lastname>\w+)", func("fn_Rx2"))
  assert.test(newStr, "Croft, Lara")

}

fn_Rx1(match, haystack) {
  if (match.Pos[0] != 1) {
    return "$"
  } else {
    return match.Value[0]
  }
}

fn_Rx2(match, haystack) {
  return match["lastname"] ", " match["firstname"]
}

ShowError(exception) {
    Msgbox, 16, Error, % "Error in " exception.what " on line " exception.Line "`n`n" exception.Message " (" A_LastError ")"  "`n"
    return true
}
