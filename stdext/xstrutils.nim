##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import
  std/strutils,
  regex,
  strformat

from parseutils import parseBiggestFloat

proc tryParseInt*(
  str: string,
  default: int = 0): tuple[ok: bool, val: int] =

  #
  # parse string 
  # let parse = "12".tryParseInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseInt)

  except:
    result = (false, default)

proc tryParseUInt*(
  str: string,
  default: uint = 0): tuple[ok: bool, val: uint] =

  #
  # parse string 
  # let parse = "12".tryParseUInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseUInt)

  except:
    result = (false, default)

proc tryParseBiggestInt*(
  str: string,
  default: BiggestInt = 0): tuple[ok: bool, val: BiggestInt] =

  #
  # parse string 
  # let parse = "12".tryParseBiggestInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseBiggestInt)

  except:
    result = (false, default)

proc tryParseBiggestUInt*(
  str: string,
  default: BiggestUInt = 0): tuple[ok: bool, val: BiggestUInt] =
  #
  # parse string 
  # let parse = "12".tryParseBiggestUInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseBiggestUInt)

  except:
    result = (false, default)

proc tryParseFloat*(
  str: string,
  default: float = 0f): tuple[ok: bool, val: float] =
  #
  # parse string 
  # let parse = "12".tryParseFloat(-1f)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0f
  # 
  #
  try:
    result = (true, str.parseFloat)

  except:
    result = (false, default)

proc tryParseBiggestFloat*(
  str: string,
  default: float64 = 0f): tuple[ok: bool, val: float64] =
  #
  # parse string 
  # let parse = "12".tryParseBiggestFloat(-1f)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0f
  # 
  #
  var val: float64
  if str.parseBiggestFloat(val) == str.len:
    result = (true, val)

  else:
    result = (false, default)

proc tryParseBinInt*(
  str: string,
  default: int = 0): tuple[ok: bool, val: int] =
  #
  # parse string 
  # let parse = "12".tryParseBinInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseBinInt)

  except:
    result = (false, default)

proc tryParseOctInt*(
  str: string,
  default: int = 0): tuple[ok: bool, val: int] =
  #
  # parse string 
  # let parse = "12".tryParseOctInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseOctInt)

  except:
    result = (false, default)

proc tryParseHexInt*(
  str: string,
  default: int = 0): tuple[ok: bool, val: int] =
  #
  # parse string 
  # let parse = "12".tryParseHexInt(-1)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is 0
  # 
  #
  try:
    result = (true, str.parseHexInt)

  except:
    result = (false, default)

proc tryParseHexStr*(
  str: string,
  default: string = "0"): tuple[ok: bool, val: string] =
  #
  # parse string 
  # let parse = "12".tryParseHexStr("A")
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is "0"
  # 
  #
  try:
    result = (true, str.parseHexStr)

  except:
    result = (false, default)

proc tryParseBool*(
  str: string,
  default: bool = false): tuple[ok: bool, val: bool] =
  #
  # parse string 
  # let parse = "12".tryParseBool(true)
  # if parse.ok:
  #   echo parse.val
  #
  # default value if not defined is false
  # 
  #
  try:
    result = (true, str.parseBool)

  except:
    result = (false, default)

proc tryParseEnum*[T](
  str: string,
  default: T): tuple[ok: bool, val: T] =
  #
  # parse string 
  # let parse = "12".tryParseEnum(MyEnum.White)
  # if parse.ok:
  #   echo parse.val
  # 
  #
  try:
    result = (true, str.parseEnum[T])

  except:
    result = (false, default)

proc toCamelCase(m: RegexMatch2, s: string): string =
  if m.captures.len != 0:
    result = s[m.group(0)].toUpper().replace("_", "")

proc toSnakeCase(m: RegexMatch2, s: string): string =
  if m.captures.len != 0:
    result = &"_{s[m.group(0)].toLower()}"

proc toCamelCase*(s: string): string =
  return s.replace(re2 "(_[a-z])", toCamelCase)

proc toSnakeCase*(s: string): string =
  result = s.replace(re2 "([A-Z])", toSnakeCase)
  if result.startsWith("_"):
    result = result.subStr(1, high(result))

proc toString*(arr: openArray[byte]): string =
  for ch in arr:
    result.add(ch.chr)
