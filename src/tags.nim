import dbase
import utils
import strformat
import strutils
import tables
import nre
import os
import osproc
import rdstdin

proc check_tag*(name:string): bool =
  if not db.tags.hasKey(name):
    log &"Tag '{name}' doesn't exist."
    return true
  return false

proc check_tag_2*(name:string): bool =
  if db.tags.hasKey(name):
    log &"Tag '{name}' already exists."
    return true
  return false

proc get_path_by_id(id:int): Path =
  for key in db.tags.keys:
    for path in db.tags[key].paths:
      if path.id == id:
        return path
  return Path()

proc get_path_index_by_id(id:int): int =
  for key in db.tags.keys:
    for i, path in db.tags[key].paths:
      if path.id == id:
        return i
  return -1

proc get_path_tag_by_id(id:int): string =
  for key in db.tags.keys:
    for path in db.tags[key].paths:
      if path.id == id:
        return key
  return ""

proc new_tag*(name:string, save:bool) =
  if check_tag_2(name):
    return
  if not is_alpha(name):
    log "Tag names must be alphanumeric."
    return
  if is_numeric(name[0]):
    log "Tag names must start with a letter."
    return
  db.tags[name] = Tag()
  if save: save_db()
  log &"Tag '{name}' created."

proc get_path_index*(name:string, path:string): int =
  for i, item in db.tags[name].paths:
    if item.path == path:
      return i
  return -1

proc add_path*(name:string, path:string) =
  if not db.tags.hasKey(name):
    new_tag(name, false)
  var path = expandTilde(path)
  if not path.startsWith("/"):
    path = getCurrentDir().joinPath(path)
  if get_path_index(name, path) != -1:
    log &"Path already exists in '{name}'."
    return
  inc(db.data.id)
  let p = Path(id:db.data.id, path:path)
  db.tags[name].paths.add(p)
  save_db()
  log(&"{path}: added to '{name}'.", "path")

proc remove_path_by_id*(sid:string) =
  var id = 0
  try:
    id = parseInt(sid)
  except:
    log "Invalid id."
    return
  let name = get_path_tag_by_id(id)
  if name == "":
    log "Can't find parent tag."
    return
  let i = get_path_index_by_id(id)
  if i != -1:
    let p = db.tags[name].paths[i]
    log(&"{p.path}: removed from '{name}'.", "path")
    db.tags[name].paths.delete(i)
    save_db()
  else:
    log "No id matched."
  return

proc remove_path*(name:string, path:string) =
  if check_tag(name):
    return
  
  if is_numeric(path):
    remove_path_by_id(path)
    return

  var res: Regex
  var use_re = false
  var removed = false

  if path.startsWith("re:"):
    res = re(scape(path.replace(re"^re:", "").strip()))
    use_re = true
  
  var i = 0

  for x in 0..(db.tags[name].paths.len - 1):
    var del = false
    let p = db.tags[name].paths[i]
    if use_re:
      let matches = p.path.find(res)
      if matches.isSome: del = true
    else:
      if p.path == path: del = true
    if del: 
      log(&"{p.path}: removed from '{name}'.", "path")
      db.tags[name].paths.delete(i)
      removed = true
    else: inc(i)
  
  if removed:
    save_db()
  else: log "Nothing was removed."

proc rename_tag*(name:string, name2:string) =
  if check_tag(name):
    return
  if check_tag_2(name2):
    return
  new_tag(name2, false)
  db.tags[name2] = db.tags[name]
  db.tags.del(name)
  save_db()
  log &"Tag '{name}' renamed to '{name2}'."

proc remove_tag*(name:string) =
  var res: Regex
  var use_re = false
  var removed = false

  if name.startsWith("re:"):
    res = re(scape(name.replace(re"^re:", "").strip()))
    use_re = true
  
  var dels = newSeq[string]()

  if use_re:
    for key in db.tags.keys:
      let match = key.find(res)
      if match.isSome:
        dels.add(key)
  else:
    if db.tags.hasKey(name):
      dels.add(name)
  
  if dels.len > 0:
    removed = true
    for key in dels:
      let ans = readLineFromStdin(&"Remove '{key}' (y/n): ").strip()
      if ans == "y":
        db.tags.del(key)
        log &"Tag '{key}' removed."
  
  if removed:
    save_db()
  else:
    log "Nothing was removed."

proc list_tags*() =
  log ""
  log("Tags:", "cyan")
  let cs = get_ansi("green")
  let rs = get_ansi("reset")
  for key in db.tags.keys:
    log &"{key} ({cs}{db.tags[key].paths.len}{rs})"
  log ""

proc list_paths*(name:string) =
  if check_tag(name):
    return

  log ""
  log(&"{name}:", "title")
  let cs = get_ansi("blue")
  let rs = get_ansi("reset")
  for path in db.tags[name].paths:
    log &"{path.path} (id:{cs}{path.id}{rs})"
  log ""

proc print_path*(sid:string) =
  var id = 0

  try:
     id = parseInt(sid)
  except:
    log "Invalid id."
    return
  
  let p = get_path_by_id(id)
  
  if p.path != "":
    echo p.path
  else:
    log "No id matched."

proc clear_tags*() =
  let ans = readLineFromStdin("Remove ALL tags (yes, no): ").strip()
  if ans == "yes":
    db.tags = initTable[string, Tag]()
    save_db()
    log "All tags were removed."