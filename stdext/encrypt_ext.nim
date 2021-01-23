#[
  License: BSD
  Author: Amru Rosyada
  Email: amru.rosyada@gmail.com
  Git: https://github.com/zendbit 
]#

proc xorEncodeDecode*(
  data: string,
  key: string): string =
  
  # xor encode decode the data with given key
  var decodedData = ""
  for i in 0..<data.len:
    decodedData &= chr(data[i].uint8 xor key[i mod 4].uint8)

  return decodedData

