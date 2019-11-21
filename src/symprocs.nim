import utils
import os
import config
import dbase
import tables

proc symdir*(): string =
  if conf.dev:
    getCurrentDir().parentDir().joinPath("sym")
  else:
    getHomeDir().joinPath("sym")

proc make_sym*(name:string, path:string) =
  let dest = symdir().joinPath(name)
  if not symlinkExists(dest):
    try:
      createSymlink(path, dest)
    except:
      log "Can't create symlink."

proc make_tag_sym*(tag:string, name:string, path:string) =
  let td = symdir().joinPath("tags").joinPath(tag)
  if not existsDir(td):
    try:
      createDir(td)
    except:
      log "Can't create tag directory."
      return
  let dest = td.joinPath(name)
  if not symlinkExists(dest):
    try:
      createSymlink(path, dest)
    except:
      log "Can't create symlink."

proc make_tag_syms*(name:string) =
  let it = db.items[name]
  for tag in it.tags:
    make_tag_sym(tag, name, it.path)

proc rename_sym*(name:string, name_2:string) =
  let sd = symdir()
  try:
    moveFile(sd.joinPath(name), sd.joinPath(name_2))
  except:
    log "Can't move symlink."
    return

  let td = sd.joinPath("tags")
  for tag in db.items[name_2].tags:
    let td2 = td.joinPath(tag)
    try:
      moveFile(td2.joinPath(name), td2.joinPath(name_2))
    except:
      log "Can't move tag symlink."
      return

proc remove_tag_sym*(name:string, tag:string) =
  let td = symdir()
    .joinPath("tags")
    .joinPath(tag)
  
  try:
    removeFile(td.joinPath(name))
  except:
    log "Can't remove tag symlink."
    return

  var n = 0
  for file in walkDir(td):
    inc(n)
  if n == 0:
    try:
      removeDir(td)
    except:
      log "Can't remove tag directory."

proc remove_sym*(name:string) =
  try:
    removeFile(symdir().joinPath(name))
  except:
    log "Can't remove symlink."
    return

  for tag in db.items[name].tags:
    remove_tag_sym(name, tag)
  
proc make_symdir*() =
  if not dirExists(symdir()):
    try:
      createDir(symdir())
      createDir(symdir().joinPath("tags"))
    except:
      log "Can't create sym directory."

proc remove_symdir*() =
  if dirExists(symdir()):
    try:
      removeDir(symdir())
    except:
      log "Can't remove sym directory."

proc remake_syms*() =
  remove_symdir()
  make_symdir()

  for name in db.items.keys:
    let it = db.items[name]
    make_sym(name, it.path)
    for tag in it.tags:
      make_tag_sym(tag, name, it.path)

  log "Symlinks remade."

proc check_symdir*() =
  if not existsDir(symdir()):
    make_symdir()
    if len(db.items) > 0:
      remake_syms()