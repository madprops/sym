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
    createSymlink(path, dest)

proc make_tag_sym*(tag:string, name:string, path:string) =
  let td = symdir().joinPath("tags").joinPath(tag)
  if not existsDir(td):
    createDir(td)
  let dest = td.joinPath(name)
  if not symlinkExists(dest):
    createSymlink(path, dest)

proc rename_sym*(name:string, name_2:string) =
  let sd = symdir()
  moveFile(sd.joinPath(name), sd.joinPath(name_2))

  let td = sd.joinPath("tags")
  for tag in db.items[name_2].tags:
    let td2 = td.joinPath(tag)
    moveFile(td2.joinPath(name), td2.joinPath(name_2))

proc remove_tag_sym*(name:string, tag:string) =
  let td = symdir()
    .joinPath("tags")
    .joinPath(tag)
  
  removeFile(td.joinPath(name))

  var n = 0
  for file in walkDir(td):
    inc(n)
  if n == 0:
    removeDir(td)

proc remove_sym*(name:string) =
  removeFile(symdir().joinPath(name))

  for tag in db.items[name].tags:
    remove_tag_sym(name, tag)

proc remake_syms*() =
  for name in db.items.keys:
    let it = db.items[name]
    make_sym(name, it.path)
    for tag in it.tags:
      make_tag_sym(tag, name, it.path)
  log "Symlinks remade."

proc make_symdir*() =
  if not dirExists(symdir()):
    createDir(symdir())
    createDir(symdir().joinPath("tags"))

proc remove_symdir*() =
  if dirExists(symdir()):
    removeDir(symdir())

proc check_symdir*() =
  if not existsDir(symdir()):
    make_symdir()
    if len(db.items) > 0:
      remake_syms()