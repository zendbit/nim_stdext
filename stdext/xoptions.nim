##
##  License: BSD
##  Author: Amru Rosyada
##  Email: amru.rosyada@gmail.com
##  Git: https://github.com/zendbit/nim.stdext
##

import options
export options

proc getOrDefault*[T](option: Option[T]): T =

  if not option.isNone(): result = option.get()
