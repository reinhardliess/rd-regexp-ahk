# Class rd_RegExp

## Installation

In a terminal or command line, navigate to your project folder:

```bash
npm install rd-regexp-ahk
```

In your code include the following:

```autohotkey
#Include, %A_ScriptDir%\node_modules\rd-regexp-ahk\rd_RegExp.ahk

re := new rd_RegExp()
```

## Description

A class to manage regular expressions in Autohotkey.

This class will always use [match objects](https://www.autohotkey.com/docs/commands/RegExMatch.htm#MatchObject), the flag `O)` will be added automatically.

All methods have function comments and if you're looking for examples check out the [tests](https://github.com/reinhardliess/rd-regexp-ahk/blob/main/tests/all-tests.ahk).

If you use the VS Code [AutoHotkey Plus Plus](https://marketplace.visualstudio.com/items?itemName=mark-wiemer.vscode-autohotkey-plus-plus) extension, you might also want to check out _Peak Definition_ (`Alt+F12`) or _Go To Definition_ (`F12`).

This class will throw an exception in case of a serious error by default which works well in combination with a [global error handler](https://www.autohotkey.com/docs/commands/OnError.htm). This behavior can be changed by setting `rd_RegExp.throwExceptions := false`.

### Methods

| Method         | Description                                                                           |
| -------------- | ------------------------------------------------------------------------------------- |
| setPcreOptions | Sets PCRE options to be auto-generated                                                |
| getPcreOptions | Gets PCRE options                                                                     |
| splitRegex     | Splits RegEx pattern into flags/pattern                                               |
| match          | Retrieves the result of matching a string against a RegEx                             |
| matchB         | For Boundfunc: Retrieves the result of matching a string against a RegEx               |
| IsMatchB       | For Boundfunc: Retrieves the _boolean_ result of matching a string against a RegEx      |
| matchAll       | retrieves all the results of matching a string against a RegEx                        |
| filterAll      | Filters array of match objects by group                                               |
| replace        | Replaces occurrences of a RegEx inside a string, optionally using a callback function |
| escapeString   | Escapes RegEx string                                                                  |
