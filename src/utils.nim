import nre
import terminal
import strformat
import strutils
import rdstdin

type Color* = enum
  blue
  cyan
  green
  red

proc get_ansi*(color:string): string =
  case color
  of "green": ansiForegroundColorCode(fgGreen)
  of "cyan": ansiForegroundColorCode(fgCyan)
  of "red": ansiForegroundColorCode(fgRed)
  of "blue": ansiForegroundColorCode(fgBlue)
  of "bright": ansiStyleCode(styleBright)
  of "reset": ansiResetCode
  else: ""

proc log*(text:string, mode="normal") =
  if mode == "normal":
    echo text
  else:
    let cr = get_ansi("reset")
    case mode
    of "title":
      let bs = get_ansi("bright")
      echo &"{bs}{text}{cr}"

proc format_tags*(tags:seq[string]): string =
  var ts = ""
  if tags.len > 0:
    for t in tags:
      ts.add(&"#{t} ")
    ts = ts.strip()
  return ts
    
proc format_item*(name:string, path:string, tags=newSeq[string]()): string =
  let cs = get_ansi("blue")
  let cs2 = get_ansi("cyan")
  let cs3 = get_ansi("green")
  let rs = get_ansi("reset")
  let ts = format_tags(tags)
  let s3 = if ts != "":
    &" {cs3}{ts}{rs}" else: &"{rs}"
  return &"{cs}{name} {cs2}{path}{s3}"

proc to_color*(s:string, color:Color): string =
  var cs = case color:
  of blue: get_ansi("blue")
  of cyan: get_ansi("cyan")
  of green: get_ansi("green")
  else: get_ansi("blue")
  let cr = get_ansi("reset")
  return &"{cs}{s}{cr}"

proc is_alpha*(s:string): bool =
  s.find(re"[^\w]+").isNone

proc is_alpha*(c:char): bool =
  return is_alpha $c

proc is_numeric*(s:string): bool =
  s.find(re"[^\d]+").isNone

proc is_numeric*(c:char): bool =
  return is_numeric $c

proc confirm*(q:string): bool =
  let ans = readLineFromStdin(&"{q} (yes/no): ").strip()
  return ans == "yes"