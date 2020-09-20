import json
export json

type
  FieldDesc* = tuple[name: string, nodeKind: JsonNodeKind]
  FieldAlias* = tuple[name: string, alias: string]

proc nodeAlias(jnode: JsonNode, fieldAlias: openArray[FieldAlias]) =
  # change the key as alias
  for (name, alias) in fieldAlias:
    let aliasElm = jnode{name}
    if not aliasElm.isNil:
      jnode.delete(name)
      jnode[alias] = aliasElm

proc toObj*[T](
  j: JsonNode,
  t: typedesc[T],
  fieldAlias: openArray[FieldAlias] = []): T =
  ##
  ## convert JsonNode to obj
  ##
  let tmp = %t()
  for k, v in j:
    var keyName = k
    var val = v
    for (name, alias) in fieldAlias:
      if k == name:
        keyName = alias
        break
    if val.kind == JNull:
      val = tmp{keyName}
    if tmp.contains(keyName):
      tmp[keyName] = val

  result = tmp.to(t)

proc fieldsDesc*(j: JsonNode): seq[FieldDesc] =
  result = @[]
  for k, v in j:
    result.add((k, v.kind))

proc toJson*[T](
  obj: T,
  fieldAlias: openArray[FieldAlias] = [],
  skipDefault: bool = true,
  skipNull: bool = false): JsonNode =
  result = %*{}
  if skipDefault:
    let tmp = %obj
    for k, v in tmp:
      var val = v
      case v.kind
      of JString:
        if v.getStr == "":
          val = newJNull()
      of JInt:
        if v.getBiggestInt == 0:
          val = newJNull()
      of JFloat:
        if v.getFloat == 0.0:
          val = newJNull()
      of JBool:
        if v.getBool:
          val = newJNull()
      else:
        discard

      if skipNull and val.kind == JNull:
        continue
      
      result[k] = val

  else:
    result = %obj

  result.nodeAlias(fieldAlias)
