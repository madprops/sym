import dbase
import config
import itemprocs
import strutils

proc check_args() =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "new", "add", "clear", "tag",
    "removepath", "removetag"]
  
  for part in conf.tail:
    if part == "": continue
    if part in actions and
      action == "":
        action = part
    else: items.add(part)
  
  if action == "": action = "add"
  
  if items.len >= 2:
    let rest = items[1..^1].join(" ")
    let rest2 = items[2..^1].join(" ")
    
    case action:
    of "add":
      add_item(items[0], items[1])
    of "rename":
      rename_item(items[0], rest)
    of "tag":
      add_tag(items[0], rest)
    of "removetag":
      remove_tag(items[0], rest)
    
  elif items.len == 1:
    case action
    of "remove":
      remove_item(items[0])
    of "removepath":
      remove_path(items[0])
    else:
      print_item(items[0])
    
  elif items.len == 0:
    case action:
    of "list":
      list_items()
    of "clear":
      clear_items()
    else: list_items()

# Main
when isMainModule:
  get_config()
  get_db()
  check_args()