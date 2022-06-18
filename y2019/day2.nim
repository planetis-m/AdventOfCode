import strutils, sugar

proc main =
   var input = readFile("data/input2.txt")
   input.stripLineEnd()
   let initialMemory = collect(newSeq, for p in input.split(','): parseInt(p))

   echo initialMemory

main()
