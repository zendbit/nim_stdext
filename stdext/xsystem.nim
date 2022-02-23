##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import
  macros,
  strutils,
  json,
  sequtils

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
  
  var nodeNameTmp: seq[string] = @[]
  var nodeName: seq[string] = @[]

  proc mergeNodeName() =
    nodeNameTmp = nodeName & nodeNameTmp
    nodeName = @[]
  
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
    var parseList = @[p]
    while parseList.len > 0:
      let nnkDot = parseList[0]
      parseList.delete(0, 1)
      for n in nnkDot:
        case n.kind:
        of nnkIdent, nnkSym:
          nodeName.add($n)
        of nnkHiddenDeref:
          if n[0].len == 0:
            nodeName.add($n[0])
          else:
            if n[0].kind == nnkDotExpr:
              parseList.add(n[0])
            else:
              nodeName.add($n[0][0] & "()")
        of nnkDerefExpr:
          if n[0].len == 0:
            nodeName.add($n[0])
          else:
            if n[0].kind == nnkDotExpr:
              parseList.add(n[0])
            else:
              nodeName.add($n[0][0] & "()[]")
        of nnkObjConstr:
          nodeName.add($n[0])
        else:
          discard

      mergeNodeName()
  else:
    discard

  result.add(newStrLitNode(nodeNameTmp.join(".")))

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
