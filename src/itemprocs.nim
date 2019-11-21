import config
import dbase
import utils
import symprocs
import strformat
import strutils
import tables
import nre
import os
import osproc
import options

proc check_item*(name:string): bool =
  if not db.items.hasKey(name):
    log &"{to_color(name, blue)} doesn't exist."
    return true
  return false

proc check_item_2*(name:string): bool =
  if db.items.hasKey(name):
    log &"{to_color(name, blue)} already exists."
    return true
  return false

proc check_tag(name:string, tag:string): bool =
  let it = db.items[name]
  if it.tags.contains(tag):
    log(&"{to_color(name, blue)} already has tag {to_color(tag, green)}")
    return true
  return false

proc get_item(name:string): Option[Item] =
  if db.items.hasKey(name):
    return some(db.items[name])
  return none(Item)

proc add_tag(name:string, tag:string) =
  if check_item(name):
    return
  
  if check_tag(name, tag):
    return

  let it = get_item(name).get
  it.tags.add(tag)
  save_db()
  make_tag_sym(tag, name, it.path)
  log &"Tag {to_color(tag, green)} added to {to_color(name, blue)}."

proc add_tags*(name:string, tags:seq[string]) =
  for tag in tags:
    add_tag(name, tag)

proc get_item_name_by_path(path:string): string =
  for name in db.items.keys:
    let it = db.items[name]
    if it.path == path:
      return name
  return ""

proc check_path(path:string): bool =
  let name = get_item_name_by_path(path)
  if name != "":
    log(&"{to_color(path, cyan)} is already used by {to_color(name, blue)}.")
    return true
  return false

proc check_dir_exists(path:string): bool =
  if not existsDir(path):
    log(&"{to_color(path, cyan)} doesn't exist.")
    return true
  return false

proc add_item*(name:string, opath:string, tags=newSeq[string]()) =
  if name.contains(" "):
    log "Item names can't have spaces."
    return
  
  var path = opath
  normalizePath(path)
  if not path.startsWith("/"):
    path = getCurrentDir().joinPath(path)
  
  if check_dir_exists(path):
    return

  if check_item_2(name):
    return
  
  if check_path(path):
    return

  let it = Item(path:path, tags:tags)
  db.items[name] = it

  var ntags: seq[string]
  for tag in tags:
    if not ntags.contains(tag):
      ntags.add(tag)

  make_sym(name, path)
  for tag in ntags:
    make_tag_sym(tag, name, path)

  save_db()
  let fmt = format_item(name, it.path, ntags)
  log(&"{fmt} added.")

proc change_path*(name:string, path:string) =
  if check_item(name):
    return
  
  if check_path(path):
    return
  
  if check_dir_exists(path):
    return
  
  remove_sym(name)
  let it = db.items[name]
  it.path = path
  make_sym(name, path)
  log(&"{to_color(name, blue)} changed to {to_color(path, cyan)}")
  save_db()

proc do_remove_item(name:string, save=true) =
  remove_sym(name)
  db.items.del(name)
  log &"{to_color(name, blue)} removed."
  if save:
    save_db()

proc remove_item_by_regex(s:string, save=true) =
  let rs = s.replace(re"^re:", "").strip()
  var res = re(rs)
  var removed = false
      
  for name in db.items.keys:
    let matches = name.find(res)
    if matches.isSome:
      do_remove_item(name, false)
      removed = true
      
  if removed: save_db()
  else: log "Nothing was removed."

proc remove_item*(name:string, save=true) =  
  if name.startsWith("re:"):
    remove_item_by_regex(name, save)
    return
  
  if check_item(name):
    return
  
  do_remove_item(name, save)

proc remove_path_by_regex*(s:string) =
  let rs = s.replace(re"^re:", "").strip()
  var res = re(rs)
  var removed = false
    
  for name in db.items.keys:
    let path = db.items[name].path
    let matches = path.find(res)
    if matches.isSome:
      do_remove_item(name, false)
      removed = true
    
  if removed: save_db()
  else: log "Nothing was removed."

proc remove_path*(path:string) =
  if path.startsWith("re:"):
    remove_path_by_regex(path)
    return

  var removed = false

  for name in db.items.keys:
    let it = db.items[name]
    if path == it.path:
      do_remove_item(name, false)
      removed = true
  
  if removed: save_db()
  else: log "Nothing was removed."

proc rename_item*(name:string, name_2:string) =
  if check_item(name):
    return
  if check_item_2(name_2):
    return

  db.items[name_2] = move db.items[name]
  db.items.del(name)
  log(&"{to_color(name, blue)} renamed to {to_color(name_2, blue)}.")
  rename_sym(name, name_2)
  save_db()

proc remove_tag*(name:string, tag:string) =
  for i in (0..db.items[name].tags.len - 1):
    let tg = db.items[name].tags[i]
    if tag == tg:
        log(&"Tag {to_color(tg, green)} removed from {to_color(name, blue)}.")
        db.items[name].tags.delete(i)
        remove_tag_sym(name, tag)
        save_db()
        return

  log "Nothing was removed."

proc print_item*(name:string) =
  if check_item(name):
    return
  let it = db.items[name]
  log(format_item(name, it.path, it.tags))

proc list_items*() =
  log ""
  log(&"Items ({len(db.items)})", "title")
  for name in db.items.keys:
    print_item(name)
  log ""

proc remove_all_items*() =
  if not conf.force and not confirm("Remove ALL items"):
    return
  
  db.items = initTable[string, Item]()
  log "All items were removed."
  remove_symdir()
  make_symdir()
  save_db()

proc list_tag*(tag:string) =
  var names: seq[string]
  for name in db.items.keys:
    let it = db.items[name]
    if it.tags.contains(tag):
      names.add(name)
    
  log ""
  let s = &"#{tag}"
  log(&"Paths in {to_color(s, green)} ({names.len})")
  for name in names:
    let it = db.items[name]
    let fmt = format_item(name, it.path)
    log fmt
  log ""

proc list_tags*() =
  var tags: seq[string]
  for name in db.items.keys:
    let it = db.items[name]
    for tag in it.tags:
      if not tags.contains(tag):
        tags.add(tag)
  
  log ""
  log(&"Tags ({tags.len})", "title")
  for tag in tags:
    let s = &"#{tag}"
    log(&"{to_color(s, green)}")
  log ""

proc open_item*(name:string) =
  if check_item(name):
    return
  let it = db.items[name]
  discard execCmd(&"xdg-open {it.path}")