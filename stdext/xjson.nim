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
  strutils,
  strformat,
  re

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
    if p(j):
      result = j

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
    result = p(j)

proc delete*(
  node: var JsonNode,
  keys: varargs[string]) =
  ##
  ##  remove node by key
  ##
  for k in keys:
    node.delete(k)

proc modify*(j: JsonNode, replaceKeys: seq[tuple[oldKey: string, newKey: string]], ignoreKeys: seq[string] = @[], ignorePairs: seq[tuple[key: string, val: JsonNode]] = @[], nested: bool = false): JsonNode =
  ##
  ##  modify JsonObject with some enhancement
  ##  - replaceKeys
  ##  - ignoreKeys
  ##  - ignorePairs
  ##  if nested true will evaluate all inside the object
  ##
  result = j

  if ignoreKeys.len > 0:
    case result.kind
    of JObject:
      for k, v in result.deepCopy:
        for key in ignoreKeys:
          if k == key:
            result.delete(key)

        if nested:
          case v.kind
          of JObject:
            result{k} = modify(v, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested)

          of JArray:
            var jArray: seq[JsonNode]
            for jObj in v:
              case jObj.kind
              of JObject:
                jArray.add(modify(jobj, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested))

              of JArray:
                for jObj_1 in jObj:
                  jArray.add(modify(jobj, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested))

              else:
                discard

            result{k} = %jArray

          else:
            discard

    of JArray:
      var jArray: seq[JsonNode] = @[]
      for jObj in result:
        jArray.add(modify(jObj, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested))

      result = %jArray

    else:
      discard

  if ignorePairs.len > 0:
    if nested:
      var buffJson = ""
      buffJson.toUgly(result)
      for pair in ignorePairs:
        buffJson = buffJson.replace(re &""""{pair.key}":{pair.val},|,"{pair.key}":{pair.val}|"{pair.key}":{pair.val}""", "")
      result = buffJson.parseJson

    else:
      case result.kind
      of JObject:
        for pair in ignorePairs:
          if not result{pair.key}.isNil and pair.val == result{pair.key}:
            result.delete(pair.key)

      of JArray:
        var jArray: seq[JsonNode] = @[]
        for jObj in result:
          jArray.add(modify(jObj, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested))

        result = %jArray

      else:
        discard

  if replaceKeys.len > 0:
    if nested:
      var buffJson = ""
      buffJson.toUgly(result)
      for key in replaceKeys:
        buffJson = buffJson.replace(&"\"{key.oldKey}\":", &"\"{key.newKey}\":")
      result = buffJson.parseJson
    else:
      case result.kind
      of JObject:
        for key in replaceKeys:
          if not result{key.oldKey}.isNil:
            let buffJson = result{key.oldKey}
            result.delete(key.oldKey)
            result{key.newKey} = buffJson

      of JArray:
        var jArray: seq[JsonNode] = @[]
        for jObj in result:
          jArray.add(modify(jObj, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested))

        result = %jArray

      else:
        discard

proc toJson*[T](t: T, replaceKeys: seq[tuple[oldKey: string, newKey: string]] = @[], ignoreKeys: seq[string] = @[], ignorePairs: seq[tuple[key: string, val: JsonNode]] = @[], nested: bool = false): JsonNode =
  ##
  ##  replace key value with specific key value pairs
  ##  if nestedReplace true will evaluate all inside the object
  ##
  result = modify(%t, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested)

proc toObject*[T](j: JsonNode, t: typedesc[T], replaceKeys: seq[tuple[oldKey: string, newKey: string]], ignoreKeys: seq[string] = @[], ignorePairs: seq[tuple[key: string, val: JsonNode]] = @[], nested: bool = false): T =
  ##
  ##  replace key value with specific key value pairs
  ##  if nestedReplace true will evaluate all inside the object
  ##
  result = modify(j, replaceKeys = replaceKeys, ignoreKeys = ignoreKeys, ignorePairs = ignorePairs, nested = nested).to(t)

proc discardNull*(j: JsonNode, nested: bool = false): JsonNode =
  ##
  ##  discard null value in the object (remove key with null value)
  ##  if nested true, will evaluated in all value inside the key
  ##
  result = j
  if nested:
    var buffJson = ""
    buffJson.toUgly(j)
    result = buffJson.replace(re""""[^"]+":null,|,"[^"]+":null|"[^"]+":null""", "").parseJson
  else:
    case j.kind
    of JObject:
      for k, v in j:
        if v.kind == JNull: result.delete(k)

    of JArray:
      var jArray: seq[JsonNode] = @[]
      for jObj in jArray:
        jarray.add(jObj.discardNull(nested = nested))

      result = %jArray

    else:
      discard
