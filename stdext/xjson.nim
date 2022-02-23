##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import
  json,
  options,
  times,
  macros,
  strutils

export
  json,
  options,
  times

import
  xoptions,
  xstrutils

export
  xoptions,
  xstrutils

# ignore field on fieldsItem, fieldsDesc, fieldsPair
template ignoreField*() {.pragma.}

type
  JFieldDesc* = tuple[name: string,
    nodeKind: JsonNodeKind]
  JFieldItem* = tuple[val: string,
    nodeKind: JsonNodeKind]
  JFieldPair* = tuple[name: string,
    val: string,
    nodeKind: JsonNodeKind]

proc `%`*(dt: DateTime): JsonNode =

  result = % $dt

proc `%`*(t: Time): JsonNode =

  result = % $t

proc `%`*(c: char): JsonNode =

  result = % $c

proc `%`*(fieldDesc: JFieldDesc): JsonNode =
 
  result = %*{"name": fieldDesc.name,
    "nodeKind": fieldDesc.nodeKind}

proc `%`*(fieldItem: JFieldItem): JsonNode =
 
  result = %*{"val": fieldItem.val,
    "nodeKind": fieldItem.nodeKind}

proc `%`*(fieldPair: JFieldPair): JsonNode =
 
  result = %*{"name": fieldPair.name,
    "val": fieldPair.val,
    "nodeKind": fieldPair.nodeKind}

proc jValue*(fieldPair: JFieldPair|JFieldItem): JsonNode =
  case fieldPair.nodeKind
  of JString:
    result = newJString(fieldPair.val)
  of JInt:
    result = newJInt(fieldPair.val.tryParseBiggestInt(0).val)
  of JFloat:
    result = newJFloat(fieldPair.val.tryParseBiggestFloat(0).val)
  of JBool:
    result = newJBool(fieldPair.val.tryParseBool(false).val)
  of JNull:
    result = newJNull()
  else:
    result = fieldPair.val.parseJson

proc jValues*(fieldPairs: openArray[JFieldPair|JFieldItem]): seq[JsonNode] =
  for f in fieldPairs:
    result.add(f.jValue)

proc names*(fieldsDesc: seq[JFieldDesc]): seq[string] =
  for f in fieldsDesc:
    result.add(f.name)

proc names*(fieldPair: seq[JFieldPair]): seq[string] =
  for f in fieldPair:
    result.add(f.name)

proc values*(fieldPair: seq[JFieldPair]): seq[string] =
  for f in fieldPair:
    result.add(f.val)

proc values*(fieldsItem: seq[JFieldItem]): seq[string] =
  for f in fieldsItem:
    result.add(f.val)

proc cleanQuote(valStr: string): string =
  result = valStr
  if valStr.startsWith("\"") and
    valStr.endsWith("\""):
    result = valStr.subStr(1, valStr.high - 1)

proc fieldDesc*[T](k: string, v: T): JFieldDesc =
  var valNodeKind: JsonNodeKind
  when v is Option:
    let val = v.getOrDefault
    if val is SomeInteger:
      valNodeKind = JInt
    elif val is SomeFloat:
      valNodeKind = JFloat
    elif val is string or val is char:
      valNodeKind = JString
    elif val is bool:
      valNodeKind = JBool
    elif val is array or val is seq:
      valNodeKind = JArray
    elif val is object or val is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull

    result = (k, valNodeKind)

  else:
    if v is SomeInteger:
      valNodeKind = JInt
    elif v is SomeFloat:
      valNodeKind = JFloat
    elif v is string or v is char:
      valNodeKind = JString
    elif v is bool:
      valNodeKind = JBool
    elif v is array or v is seq:
      valNodeKind = JArray
    elif v is object or v is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull

    result = (k, valNodeKind)

proc fieldDesc*[T: object|ref object](obj: T): seq[JFieldDesc] =
  when obj is object:
    for k, v in obj.fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(k.fieldDesc(v))
  else:
    for k, v in obj[].fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(k.fieldDesc(v))

proc fieldPair*[T](k: string, v: T): JFieldPair =
  var valStr = ""
  var valNodeKind: JsonNodeKind
  when v is Option:
    let val = v.getOrDefault
    if val is SomeInteger:
      valNodeKind = JInt
    elif val is SomeFloat:
      valNodeKind = JFloat
    elif val is string or val is char:
      valNodeKind = JString
    elif val is bool:
      valNodeKind = JBool
    elif val is array or val is seq:
      valNodeKind = JArray
    elif val is object or val is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull

    if v.isSome:
      if valNodeKind in [JArray, JObject]:
        valStr = ($ %val).cleanQuote
      else:
        valStr = $val
    else:
      valStr = "null"

    result = (k, valStr, valNodeKind)

  else:
    if v is SomeInteger:
      valNodeKind = JInt
    elif v is SomeFloat:
      valNodeKind = JFloat
    elif v is string or v is char:
      valNodeKind = JString
    elif v is bool:
      valNodeKind = JBool
    elif v is array or v is seq:
      valNodeKind = JArray
    elif v is object or v is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull
      
    if valNodeKind in [JArray, JObject]:
      valStr = ($ %v).cleanQuote
    elif valNodeKind == JNull:
      valStr = "null"
    else:
      valStr = $v

    result = (k, valStr, valNodeKind)

proc fieldPair*[T: object|ref object](obj: T): seq[JFieldPair] =
  when obj is object:
    for k, v in obj.fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(k.fieldPair(v))
  else:
    for k, v in obj[].fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(k.fieldPair(v))

proc fieldItem*[T](v: T): JFieldItem =
  var valStr = ""
  var valNodeKind: JsonNodeKind
  when v is Option:
    let val = v.getOrDefault
    if val is SomeInteger:
      valNodeKind = JInt
    elif val is SomeFloat:
      valNodeKind = JFloat
    elif val is string or val is char:
      valNodeKind = JString
    elif val is bool:
      valNodeKind = JBool
    elif val is array or val is seq:
      valNodeKind = JArray
    elif val is object or val is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull

    if v.isSome:
      if valNodeKind in [JArray, JObject]:
        valStr = ($ %val).cleanQuote
      else:
        valStr = $val
    else:
      valStr = "null"

    result = (valStr, valNodeKind)

  else:
    if v is SomeInteger:
      valNodeKind = JInt
    elif v is SomeFloat:
      valNodeKind = JFloat
    elif v is string or v is char:
      valNodeKind = JString
    elif v is bool:
      valNodeKind = JBool
    elif v is array or v is seq:
      valNodeKind = JArray
    elif v is object or v is ref object:
      valNodeKind = JObject
    else:
      valNodeKind = JNull
      
    if valNodeKind in [JArray, JObject]:
      valStr = ($ %v).cleanQuote
    elif valNodeKind == JNull:
      valStr = "null"
    else:
      valStr = $v

    result = (valStr, valNodeKind)

proc fieldItem*[T: object|ref object](obj: T): seq[JFieldItem] =
  when obj is object:
    for k, v in obj.fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(fieldItem(v))
  
  else:
    for k, v in obj[].fieldPairs:
      when not v.hasCustomPragma(ignoreField):
        result.add(fieldItem(v))

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

proc discardNull*(j: JsonNode): JsonNode =
  case j.kind
  of JObject:
    return j.filter(proc (x: JsonNode): bool = x{"val"}.kind != JNull)
  of JArray:
    return j.filter(proc (x: JsonNode): bool = x.kind != JNull)
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc delete*(
  node: var JsonNode,
  keys: varargs[string]) =
  for k in keys:
    node.delete(k)

