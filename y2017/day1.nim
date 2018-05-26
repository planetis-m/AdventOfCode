proc toDigitSeq(s: string): seq[int] =
   const digits = {'0' .. '9'}
   for i in 0 .. high(s):
      if s[i] in digits:
         result.add(int(s[i]) - int('0'))
      else:
         break

proc solve(s: seq[int]; secondPart = false): int =
   # sum equals with stride
   let n = len(s)
   let stride =
      if secondPart: n div 2
      else: 1
   for i in 0 ..< n:
      if s[i] == s[(i + stride) mod n]: # cyclic equals
         result += s[i]

let input = toDigitSeq(readFile("input1.txt"))
echo solve(input)
echo solve(input, true)
