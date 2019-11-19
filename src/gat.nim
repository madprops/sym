import utils
import dbase
import config
import tags
import strutils

proc check_args() =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "new", "add", "clear"]
  
  for part in conf.tail:
    if part == "": continue
    if part in actions and
      action == "":
        action = part
    else: items.add(part)
  
  if action == "": action = "add"
  
  if items.len >= 2:
    let rest = items[1..^1].join(" ")
    
    case action:
    of "add":
      add_path(items[0], rest)
    of "rename":
      rename_tag(items[0], rest)
    of "remove":
      remove_path(items[0], rest)
    
  elif items.len == 1:
    case action
    of "new":
      new_tag(items[0], true)
    of "remove":
      if is_numeric(items[0]):
        remove_path_by_id(items[0])
      else:
        remove_tag(items[0])
    of "list":
      list_paths(items[0])
    else:
      if is_numeric(items[0]):
        print_path(items[0])
      else:
        list_paths(items[0])
    
  elif items.len == 0:
    case action:
    of "list":
      list_tags()
    of "clear":
      clear_tags()
    else: list_tags()

# Main
when isMainModule:
  get_config()
  get_db()
  check_args()