import std/os
import std/nre
import std/terminal
import std/strformat
import std/strutils
import std/rdstdin
import config

type AnsiKind* = enum
  green
  cyan
  red
  blue
  bright
  reset

proc get_ansi*(kind:string): string =
  case kind
  of "green": ansiForegroundColorCode(fgGreen)
  of "cyan": ansiForegroundColorCode(fgCyan)
  of "red": ansiForegroundColorCode(fgRed)
  of "blue": ansiForegroundColorCode(fgBlue)
  of "bright": ansiStyleCode(styleBright)
  of "reset": ansiResetCode
  else: ""

proc get_ansi*(kind:AnsiKind): string =
  case kind
  of green: get_ansi("green")
  of cyan: get_ansi("cyan")
  of red: get_ansi("red")
  of blue: get_ansi("blue")
  of bright: get_ansi("bright")
  of reset: get_ansi("reset")

proc log*(text:string, mode="normal") =
  if mode == "normal":
    echo text
  else:
    let cr = get_ansi("reset")
    case mode
    of "title":
      let bs = get_ansi("bright")
      echo &"{bs}{text}{cr}"

proc format_tags*(tags:seq[string], hash=true): string =
  let hsh = if hash: "#" else: ""
  var ts = ""
  if tags.len > 0:
    for t in tags:
      ts.add(&"{hsh}{t} ")
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

proc to_color*(s:string, color:AnsiKind): string =
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

proc fix_path*(path:string): string =
  var path = expandTilde(path)
  normalizePath(path)
  if not path.startsWith("/"):
    path = getCurrentDir().joinPath(path)
  return path

proc fix_path_2*(path:string): string =
  var path = expandTilde(path)
  normalizePath(path)
  if not path.startsWith("/"):
    path = if conf.dev:
      getCurrentDir().parentDir().joinPath(path)
      else: getCurrentDir().joinPath(path)
  return path

proc lined*(items:seq[string]): string =
  return items.join(" ")
