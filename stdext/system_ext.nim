##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import macros, strutils

macro nameof*(p: typed): untyped =
  ##
  ##  this is for get name of the object or field
  ##  ex:
  ##  type Users = object
  ##    name: string 
  ##
  ##  echo nameof(Users)
  ##  echo nameof(Users.name)
  ##
  result = newStmtList()
  
  var nodeName: seq[string] = @[]
  
  case p.kind:
  of nnkIdent, nnkSym:
    nodeName.add($p)
  of nnkDotExpr:
    for n in p:
      nodeName.add($n)
  else:
    nodeName.add("")

  result.add(newStrLitNode(nodeName.join(".")))

template `$@`*(p: typed): untyped =
  ##
  ##  same with nameof macro, return name of the type
  ##  echo $@Users.id
  ##
  nameof p
