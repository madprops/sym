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

proc log*(text:string, color="", colormode="all") =
  let cs = get_ansi(color)
  let cr = get_ansi("reset")
  if colormode == "all":
    echo &"{cs}{text}{cr}"
  elif colormode == "start":
    let split = text.split(": ")
    let t1 = split[0].strip()
    let t2 = split[1].strip()
    echo &"{cs}{t1}:{cr} {t2}"