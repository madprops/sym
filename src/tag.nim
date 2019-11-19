import config
import tags
import strutils

proc check_args() =
  var action = ""
  var items: seq[string]
  let actions = ["remove", "rename",
    "list", "new", "add"]
  
  for part in conf.tail:
    if part == "": continue
    if part in actions and
      action == "":
        action = part
    else: items.add(part)
  
  if action == "": action = "add"
  
  if items.len >= 2:
    let rest = items[1..^1].join(" ")
  
    if action == "add":
      add_path(items[0], rest)
    elif action == "rename":
      rename_tag(items[0], rest)
    elif action == "remove":
      remove_path(items[0], rest)
    
  elif items.len == 1:
    if action == "new":
      new_tag(items[0], true)
    elif action == "remove":
      remove_tag(items[0])
    elif action == "list":
      list_paths(items[0])
    else: list_paths(items[0])
    
  elif items.len == 0:
    if action == "list":
      list_tags()
    else: list_tags()

# Main
when isMainModule:
  get_config()
  get_tags()
  check_args()