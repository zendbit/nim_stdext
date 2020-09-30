import json, options
export json

type
  FieldDesc* = tuple[name: string, nodeKind: JsonNodeKind]
  FieldAlias* = tuple[name: string, alias: string]

proc `%`*(fieldDesc: FieldDesc): JsonNode =
  return %*{"name": fieldDesc.name, "nodeKind": fieldDesc.nodeKind}

proc `%`*(fieldAlias: FieldAlias): JsonNode =
  return %*{"name": fieldAlias.name, "nodeKind": fieldAlias.alias}

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

#proc fieldsDesc*[T: object](obj: T): seq[FieldDesc] =
#  for k, v in obj.fieldPairs:
#    if v is Option:
#      result.add((k, (%v.getOrDefault).kind))
#    else:
#      result.add((k, (%v).kind))

proc filter*(j: JsonNode, p: proc (x: JsonNode): bool): JsonNode =
  case j.kind
  of JObject:
    result = newJObject()
    for k, v in j:
      if p(v):
        result[k] = v
  of JArray:
    result = newJArray()
    for v in j:
      if p(v):
        result.add(v)
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc discardNull*(j: JsonNode): JsonNode =
  result = j.filter(proc (x: JsonNode): bool = x.kind == JArray)

proc toJson*[T](
  obj: T,
  fieldsAlias: openArray[FieldAlias] = [],
  defaultNull: bool = true,
  discardNull: bool = false,
  excludes: openArray[string] = []): JsonNode =
  result = %*{}
  let tmp = %obj
  for k, v in tmp:
    if k in excludes:
      continue
    var val = v
    if defaultNull:
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

    if discardNull and val.kind == JNull:
      continue
    
    result[k] = val

  result.nodeAlias(fieldsAlias)

proc delete*(node: JsonNode, keys: openArray[string]): JsonNode =
  result = node
  for k in keys:
    result.delete(k)

