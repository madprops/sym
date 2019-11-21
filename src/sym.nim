import utils
import dbase
import config
import os
import itemprocs
import symprocs
import strutils

proc do_action(tail:seq[string]) =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "add", "removeall", "tag", "removepath", 
    "removetag", "tags", "changepath", "open",
    "backup", "restore", "remake"]
    
  for part in tail:
    if part == "": continue
    if part in actions and
      action == "":
        action = part
    else: items.add(part)
    
  if action == "": action = "add"
    
  if items.len >= 2:
    let rtail = items[1..^1]
    let rtail2 = items[2..^1]
      
    case action
    of "add":
      add_item(items[0], items[1], rtail2)
    of "rename":
      rename_item(items[0], items[1])
    of "tag":
      add_tags(items[0], rtail)
    of "removetag":
      remove_tag(items[0], items[1])
    of "changepath":
      change_path(items[0], items[1])
      
  elif items.len == 1:
    case action
    of "remove":
      remove_item(items[0])
    of "removepath":
      remove_path(items[0])
    of "tag":
      list_tag(items[0])
    of "open":
      open_item(items[0])
    else:
      print_item(items[0])
      
  elif items.len == 0:
    case action
    of "list":
      list_items()
    of "tags":
      list_tags()
    of "removeall":
      remove_all_items()
    of "restore":
      restore_backup()
      remake_syms()
    of "backup":
      save_backup()
    of "remake":
      remake_syms()
    else: show_info()

proc check_args() =
  if conf.script != "":
    var text = ""
    var path = expandTilde(conf.script)
    if not path.startsWith("/"):
      path = if conf.dev:
        getCurrentDir().parentDir().joinPath(conf.script)
      else: getCurrentDir().joinPath(conf.script)
    try:
      text = readFile(path)
    except:
      log "Can't read script file."
    for line in text.splitLines:
      if line.strip() == "": continue
      do_action(line.split(" "))
  else:
    do_action(conf.tail)

# Main
when isMainModule:
  get_config()
  get_db()
  check_symdir()
  check_args()