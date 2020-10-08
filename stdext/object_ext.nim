import json

proc patch*[T: object | ref object](self: T, patch: T): T =
  let tmp = %self
  for k, v in %patch:
    if tmp.hasKey(k) and v.kind != JNull:
      tmp[k] = v

  return tmp.to(T)

