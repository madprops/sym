import utils
import dbase
import config
import itemprocs
import symprocs
import strutils

var started = false

proc startup() =
  if started: return
  get_db()
  check_symdir()
  started = true

proc do_action(tail:seq[string]) =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "add", "removeall", "tag", "removepath", 
    "removetag", "tags", "changepath", "open",
    "backup", "restore", "remake", "makescript",
    "path", "printnames"]
    
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
      startup()
      add_item(items[0], items[1], rtail2)
    of "rename":
      startup()
      rename_item(items[0], items[1])
    of "tag":
      startup()
      add_tags(items[0], rtail)
    of "removetag":
      startup()
      remove_tag(items[0], items[1])
    of "changepath":
      startup()
      change_path(items[0], items[1])
      
  elif items.len == 1:
    case action
    of "remove":
      startup()
      remove_item(items[0])
    of "removepath":
      startup()
      remove_path(items[0])
    of "tag":
      startup()
      list_tag(items[0])
    of "open":
      startup()
      open_item(items[0])
    of "makescript":
      make_script(items[0])
    of "path":
      startup()
      show_path(items[0])
    else:
      startup()
      print_item(items[0])
      
  elif items.len == 0:
    case action
    of "list":
      startup()
      list_items()
    of "tags":
      startup()
      list_tags()
    of "removeall":
      startup()
      remove_all_items()
    of "restore":
      startup()
      restore_backup()
      remake_syms()
    of "backup":
      startup()
      save_backup()
    of "remake":
      startup()
      remake_syms()
    of "printnames":
      startup()
      print_item_names()
    else: show_info()

proc run_script(path:string) =
  var text = ""
  var path = fix_path_2(path)
  try:
    text = readFile(path)
  except:
    log "Can't read script file."
    return
  for line in text.splitLines:
    if line.strip() == "": continue
    do_action(line.split(" "))

proc check_args() =
  if conf.tail.len > 0:
    if conf.tail[0] == "runscript":
      run_script(conf.tail[1..^1].join(" "))
      return
  do_action(conf.tail)

# Main
when isMainModule:
  get_config()
  check_args()