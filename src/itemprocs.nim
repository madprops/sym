import dbase
import utils
import strformat
import strutils
import tables
import nre
import os
import rdstdin
import options

proc check_item*(name:string): bool =
  if not db.items.hasKey(name):
    log &"'{name}' doesn't exist."
    return true
  return false

proc check_item_2*(name:string): bool =
  if db.items.hasKey(name):
    log &"'{name}' already exists."
    return true
  return false

proc get_item(name:string): Option[Item] =
  if db.items.hasKey(name):
    return some(db.items[name])
  return none(Item)

proc add_tag*(name:string, tag:string) =
  var tag = tag.toLower()
  if check_item(name):
    return
  let it = get_item(name).get
  if it.tags.contains(tag):
    log "That tag is already set."
    return
  it.tags.add(tag)
  save_db()
  log &"Tag '{tag}' added to '{name}'."

proc add_item*(name:string, path:string, full:bool=true) =
  if check_item_2(name):
    return

  var path = expandTilde(path)
  if not path.startsWith("/"):
    path = getCurrentDir().joinPath(path)

  let it = Item(path:path, tags:newSeq[string]())
  db.items[name] = it

  if full:
    save_db()
    let fmt = format_item(name, it.path, it.tags)
    log(&"{fmt} added.")

proc remove_item*(name:string) =
  if check_item(name):
    return
  db.items.del(name)
  log &"'{name}' removed."
  save_db()

proc remove_path_by_regex*(s:string) =
  let rs = s.replace(re"^re:", "").strip()
  var res = re(rs)
  var removed = false
    
  for name in db.items.keys:
    let path = db.items[name].path
    let matches = path.find(res)
    if matches.isSome:
      let ans = readLineFromStdin(&"Remove '{name}' ({path}) (y/n): ").strip()
      if ans == "y":
        let fmt = format_item(name, path)
        log(&"{fmt} removed.")
        db.items.del(name)
        removed = true
    
  if removed: save_db()
  else: log "Nothing was removed."

proc remove_path*(path:string) =
  if path.startsWith("re:"):
    remove_path_by_regex(path)
    return

  for name in db.items.keys:
    let it = db.items[name]
    if path == it.path:
      db.items.del(name)        
      let fmt = format_item(name, path)
      log(&"{fmt} removed.")
      save_db()
      return
  
  log "Nothing was removed."

proc rename_item*(name:string, name_2:string) =
  if check_item(name):
    return
  if check_item_2(name_2):
    return

  db.items[name_2] = move db.items[name]
  db.items.del(name)
  log &"'{name}' renamed to '{name_2}'."
  save_db()

proc remove_tag*(name:string, tag:string) =
  for i in (0..db.items[name].tags.len - 1):
    let tg = db.items[name].tags[i]
    if tag == tg:
        log &"Tag '{tg}' removed."
        db.items[name].tags.delete(i)
        save_db()
        return

  log "Nothing was removed."

proc print_item*(name:string) =
  let it = db.items[name]
  log(format_item(name, it.path, it.tags))

proc list_items*() =
  log ""
  log(&"Items ({len(db.items)})", "title")
  log ""
  let cs = get_ansi("green")
  let rs = get_ansi("reset")
  for name in db.items.keys:
    print_item(name)
  log ""

proc clear_items*() =
  let ans = readLineFromStdin("Remove ALL items (yes, no): ").strip()
  if ans == "yes":
    db.items = initTable[string, Item]()
    log "All tags were removed."
    save_db()