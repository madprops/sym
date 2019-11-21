import dbase
import config
import itemprocs
import symprocs

proc check_args() =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "add", "removeall", "tag", "removepath", 
    "removetag", "tags", "changepath", "open",
    "backup", "restore"]
  
  for part in conf.tail:
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
    else: show_info()

# Main
when isMainModule:
  get_config()
  get_db()
  check_symdir()
  check_args()