import nre
import terminal
import strformat
import strutils

proc get_ansi*(color:string): string =
  case color
  of "green": ansiForegroundColorCode(fgGreen)
  of "cyan": ansiForegroundColorCode(fgCyan)
  of "red": ansiForegroundColorCode(fgRed)
  of "blue": ansiForegroundColorCode(fgBlue)
  of "reset": ansiResetCode
  else: ""

proc log*(text:string, mode="normal") =
  if mode == "normal":
    echo text
  elif mode == "path":
    let cs = get_ansi("green")
    let cs2 = get_ansi("blue")
    let cr = get_ansi("reset")
    let split = text.split(": ")
    var t1 = split[0].strip()
    var t2 = split[1].strip()
      .replace(re"'(.*)'", &"{cs2}$1{cr}")
    echo &"{cs}{t1}{cr} {t2}"

proc is_alpha*(s:string): bool =
  s.find(re"[^\w]+").isNone

proc is_alpha*(c:char): bool =
  return isAlphaAscii(c)

proc scape*(s:string): string =
  s.replace("\\", "\\\\")