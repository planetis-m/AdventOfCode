proc toDigitSeq(s: string): seq[int8] =
   result = @[]
   var i = 0
   while s[i] in {'0'..'9'}:
      result.add int8(s[i]) - int8('0')
      inc i

template cyclicEqual: bool =
   arr[i] == arr[(i + d) mod n]

proc solve(arr: seq[int8]; secondPart = false): int =
   let n = len(arr)
   let d =
      if secondPart: n div 2 
      else: 1
   for i in 0 ..< n:
      if cyclicEqual():
         result += arr[i]

let inputArr = toDigitSeq(readFile("captcha.txt"))
echo solve(inputArr)
echo solve(inputArr, true)
