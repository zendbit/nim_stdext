##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import options
export options

proc getOrDefault*(option: Option[int]): int =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[uint]): uint =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[int64]): int64 =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[uint64]): uint64 =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[float64]): float64 =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[float32]): float32 =

  if not option.isNone: result = option.get

proc getOrDefault*(option: Option[string]): string =

  if not option.isNone: result = option.get

proc getOrDefault*[i, T](option: Option[array[i, T]]): array[i, T] =

  if not option.isNone: result = option.get

proc getOrDefault*[T](option: Option[openArray[T]]): openArray[T] =

  if not option.isNone: result = option.get

proc getOrDefault*[T](option: Option[T]): T =

  if not option.isNone: result = option.get
