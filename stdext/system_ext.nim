##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import macros, strutils, json

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
  
  var nodeName: string = ""
  
  case p.kind:
  of nnkIdent, nnkSym:
    nodeName = $p
  of nnkHiddenDeref, nnkDerefExpr:
    nodeName = $p[0][0]
  of nnkObjConstr:
    nodeName = $p[0]
  of nnkDotExpr:
    for n in p:
      case n.kind:
      of nnkIdent, nnkSym:
        nodeName = $n
      of nnkHiddenDeref, nnkDerefExpr:
        nodeName = $n[0][0]
      of nnkObjConstr:
        nodeName = $n[0]
      else:
        discard
  else:
    discard

  result.add(newStrLitNode(nodeName))

macro fnameof*(p: typed): untyped =
  ##
  ##  this is for get name of the object or field
  ##  this will return string of the input rather than get the name
  ##  Users().name will convert to "Users().name"
  ##
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
  of nnkHiddenDeref:
    nodeName.add($p[0][0] & "()")
  of nnkDerefExpr:
    nodeName.add($p[0][0] & "()[]")
  of nnkObjConstr:
    nodeName.add($p[0] & "()")
  of nnkDotExpr:
    for n in p:
      case n.kind:
      of nnkIdent, nnkSym:
        nodeName.add($n)
      of nnkHiddenDeref:
        nodeName.add($n[0][0] & "()")
      of nnkDerefExpr:
        nodeName.add($n[0][0] & "()[]")
      of nnkObjConstr:
        nodeName.add($n[0] & "()")
      else:
        discard
  else:
    discard

  result.add(newStrLitNode(nodeName.join(".")))

template `$@`*(p: typed): untyped =
  ##
  ##  same with nameof macro, return name of the type
  ##  echo $@Users.id
  ##
  nameof p

template `$>`*(p: typed): untyped =
  ##
  ##  same with nameof macro, return fnamef of the type
  ##  echo $@Users.id
  ##
  fnameof p
  
proc patch*[T: object | ref object](self: T, patch: T): T =
  ##
  ##  Patch object with new instance
  ##
  let tmp = %self
  for k, v in %patch:
    if tmp.hasKey(k) and v.kind != JNull:
      tmp[k] = v

  result = tmp.to(T)
