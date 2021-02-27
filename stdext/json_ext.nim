import json, options
import options_ext
export json

type
  FieldDesc* = tuple[name: string, nodeKind: JsonNodeKind]
  FieldItem* = tuple[val: string, nodeKind: JsonNodeKind]
  FieldsPair* = tuple[name: string, val: string, nodeKind: JsonNodeKind]

proc `%`*(fieldDesc: FieldDesc): JsonNode =
 
  result = %*{"name": fieldDesc.name, "nodeKind": fieldDesc.nodeKind}

proc fieldsDesc*(j: JsonNode): seq[FieldDesc] =

  for k, v in j:
    result.add((k, v.kind))

proc fieldsItem*(j: JsonNode): seq[FieldItem] =

  for k, v in j:
    result.add((k, v.kind))

proc fieldsPair*(j: JsonNode): seq[FieldsPair] =
  
  for k, v in j:
    if v.kind != JString:
      result.add((k, $v, v.kind))
    else:
      result.add((k, v.getStr, v.kind))

proc names*(fieldsDesc: seq[FieldDesc]): seq[string] =
  for f in fieldsDesc:
    result.add(f.name)

proc names*(fieldsPair: seq[FieldsPair]): seq[string] =
  for f in fieldsPair:
    result.add(f.name)

proc values*(fieldsPair: seq[FieldsPair]): seq[string] =
  for f in fieldsPair:
    result.add(f.val)

proc values*(fieldsItem: seq[FieldItem]): seq[string] =
  for f in fieldsItem:
    result.add(f.val)

proc fieldsDesc*[T](obj: T): seq[FieldDesc] =
  for k, v in obj.fieldPairs:
    let vtype = cast[type v](v)
    if vtype is Option:
      if vtype is Option[SomeInteger]:
        result.add((k, JInt))
      elif vtype is Option[SomeFloat]:
        result.add((k, JFloat))
      elif vtype is Option[string]:
        result.add((k, JString))
      elif vtype is Option[bool]:
        result.add((k, JBool))
      elif vtype is Option[array] or vType is Option[seq]:
        result.add((k, JArray))
      elif vtype is Option[RootObj]:
        result.add((k, JObject))
      else:
        result.add((k, JNull))
    else:
      if v is SomeInteger:
        result.add((k, JInt))
      elif v is SomeFloat:
        result.add((k, JFloat))
      elif v is string:
        result.add((k, JString))
      elif v is bool:
        result.add((k, JBool))
      elif v is array or v is seq:
        result.add((k, JArray))
      elif v is RootObj:
        result.add((k, JObject))
      else:
        result.add((k, JNull))

proc fieldsPair*[T](obj: T): seq[FieldsPair] =
  for k, v in obj.fieldPairs:
    let vtype = cast[type v](v)
    if vtype is Option:
      if vtype is Option[SomeInteger]:
        result.add((k, $ v.getOrDefault, JInt))
      elif vtype is Option[SomeFloat]:
        result.add((k, $ v.getOrDefault, JFloat))
      elif vtype is Option[string]:
        result.add((k, $ v.getOrDefault, JString))
      elif vtype is Option[bool]:
        result.add((k, $ v.getOrDefault, JBool))
      elif vtype is Option[array] or vType is Option[seq]:
        result.add((k, $ v.getOrDefault, JArray))
      elif vtype is Option[RootObj]:
        result.add((k, $ v.getOrDefault, JObject))
      else:
        result.add((k, $ v.getOrDefault, JNull))
    else:
      if v is SomeInteger:
        result.add((k, $ v.getOrDefault, JInt))
      elif v is SomeFloat:
        result.add((k, $ v.getOrDefault, JFloat))
      elif v is string:
        result.add((k, $v, JString))
      elif v is bool:
        result.add((k, $v, JBool))
      elif v is array or v is seq:
        result.add((k, $v, JArray))
      elif v is RootObj:
        result.add((k, $v, JObject))
      else:
        result.add((k, $v, JNull))

proc fieldsItem*[T](obj: T): seq[FieldItem] =
  for k, v in obj.fieldPairs:
    let vtype = cast[type v](v)
    if vtype is Option:
      if vtype is Option[SomeInteger]:
        result.add((k, JInt))
      elif vtype is Option[SomeFloat]:
        result.add((k, JFloat))
      elif vtype is Option[string]:
        result.add((k, JString))
      elif vtype is Option[bool]:
        result.add((k, JBool))
      elif vtype is Option[array] or vType is Option[seq]:
        result.add((k, JArray))
      elif vtype is Option[RootObj]:
        result.add((k, JObject))
      else:
        result.add((k, JNull))
    else:
      if v is SomeInteger:
        result.add((k, JInt))
      elif v is SomeFloat:
        result.add((k, JFloat))
      elif v is string:
        result.add((k, JString))
      elif v is bool:
        result.add((k, JBool))
      elif v is array or v is seq:
        result.add((k, JArray))
      elif v is RootObj:
        result.add((k, JObject))
      else:
        result.add((k, JNull))

proc filter*(
  j: JsonNode,
  p: proc (x: JsonNode): bool): JsonNode =

  case j.kind
  of JObject:
    result = newJObject()
    for k, v in j:
      if p(%*{"key": k, "val": v}):
        result[k] = v
  of JArray:
    result = newJArray()
    for v in j:
      if p(v):
        result.add(v)
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc discardNull*(j: JsonNode): JsonNode =
  case j.kind
  of JObject:
    return j.filter(proc (x: JsonNode): bool = x{"val"}.kind != JNull)
  of JArray:
    return j.filter(proc (x: JsonNode): bool = x.kind != JNull)
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc map*(
  j: JsonNode,
  p: proc (x: JsonNode): JsonNode): JsonNode =

  case j.kind
  of JObject:
    result = newJObject()
    for k, v in j:
      result[k] = p(%*{"key": k, "val": v})
  of JArray:
    result = newJArray()
    for v in j:
      result.add(p(v))
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc delete*(
  node: JsonNode,
  keys: openArray[string]): JsonNode =
  result = node
  for k in keys:
    result.delete(k)

