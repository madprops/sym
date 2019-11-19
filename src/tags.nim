import utils
import config
import json
import strformat
import strutils
import tables
import nre
import os

type Tag = object
  paths: seq[string]

var tags: Table[string, Tag]

proc get_tags*() =
  let path = if conf.dev: "../tags.json"
    else: "~/.config/tag/tags.json"
  let tags_json = parseJson(readFile(path))
  tags = to(tags_json, Table[string, Tag])

proc save_tags*() = 
  var tags_json = % tags
  writeFile("tags.json", tags_json.pretty())

proc check_tag*(name:string): bool =
  if not tags.hasKey(name):
    log &"Tag '{name}' doesn't exist."
    return true
  return false

proc check_tag_2*(name:string): bool =
  if tags.hasKey(name):
    log &"Tag '{name}' already exists."
    return true
  return false

proc new_tag*(name:string, save:bool) =
  if check_tag_2(name):
    return
  tags[name] = Tag()
  if save: save_tags()
  log &"Tag '{name}' created."

proc add_path*(name:string, path:string)=
  if not tags.hasKey(name):
    new_tag(name, false)
  var path = expandTilde(path)
  if not path.startsWith("/"):
    path = getCurrentDir().joinPath(path)
  if tags[name].paths.contains(path):
    log &"Path already exists in '{name}'."
    return
  tags[name].paths.add(path)
  save_tags()
  log &"{path} added to '{name}'."

proc remove_path*(name:string, path:string)=
  if check_tag(name):
    return

  var ix = newSeq[int]()
  var res: Regex
  var use_re = false
  var removed = false

  if path.startsWith("re:"):
    res = re(path.replace(re"^re:", "").strip())
    use_re = true
  
  var i = 0

  for x in 0..(tags[name].paths.len - 1):
    var del = false
    let p = tags[name].paths[i]
    if use_re:
      let matches = p.find(res)
      if matches.isSome: del = true
    else:
      if p == path: del = true
    if del: 
      log &"{p} removed from '{name}'"
      tags[name].paths.delete(i)
      removed = true
    else: inc(i)
  
  if removed:
    save_tags()
  else: log "Nothing was deleted."

proc rename_tag*(name:string, name2:string) =
  if check_tag(name):
    return
  if check_tag_2(name2):
    return
  new_tag(name2, false)
  tags[name2] = tags[name]
  tags.del(name)
  save_tags()
  log &"Tag '{name}' renamed to '{name2}'."

proc remove_tag*(name:string) =
  if check_tag(name):
    return
  tags.del(name)
  save_tags()
  log &"Tag '{name}' removed."

proc list_tags*() =
  log ""
  log("Tags:", "cyan")
  for key in tags.keys:
    log &"{key} ({tags[key].paths.len})"
  log ""

proc list_paths*(name:string) =
  if check_tag(name):
    return

  log ""
  log(&"{name}:", "cyan")
  for path in tags[name].paths:
    log path
  log ""