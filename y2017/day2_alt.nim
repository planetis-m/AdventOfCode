import strutils, algorithm #, combinatorics

type
   Spreadsheet = object
      offsets: seq[int]
      data: seq[int]

proc readData(fname: string): seq[seq[string]] =
   var fh: File
   var succeeded: bool
   try:
      fh = open(fname, fmRead)
      succeeded = true
      for line in lines(fh):
         if line != "\n":
            let it = line.strip.split('\t')
            result.add(it)
   except IOError:
      echo("cannot open ", fname)
   finally:
      if succeeded:
         close(fh)

proc initSpreadsheet(data: seq[seq[string]]): Spreadsheet =
   var inner = 0
   for d in data:
      inner += d.len
   result.data = newSeq[int](inner)
   result.offsets = newSeq[int](data.len)
   inner = 0
   var count = 0
   for i, d in data:
      inner += d.len
      result.offsets[i] = inner
      for s in d:
         result.data[count] = parseInt(s)
         count.inc

proc sortEachRow(s: var Spreadsheet) =
   var prev = 0
   for i in 0 ..< s.offsets.len:
      sort(toOpenArray(s.data, prev, s.offsets[i] - 1), cmp)
      prev = s.offsets[i]

template notSortedRows(s) =
   assert isSorted(toOpenArray(s.data, 0, s.offsets[0] - 1), cmp)

proc checksum0(s: Spreadsheet): int =
   notSortedRows(s)
   var prev = 0
   for i in 0 ..< s.offsets.len:
      result += s.data[s.offsets[i] - 1] - s.data[prev]
      prev = s.offsets[i]

# proc checksum(s: Spreadsheet): int =
#    notSortedRows(s)
#    for i in 0 ..< s.offsets.len:
#       var d = 0
#       var prev = 0
#       for p in combinations(toOpenArray(s.data, prev, s.offsets[i] - 1), 2):
#          if p[1] mod p[0] == 0:
#             d = p[1] div p[0]
#       prev = s.offsets[i]
#       result += d

# let input = "5 1 9 5\n7 5 3\n2 4 6 8\n"
# let data = input.splitLines.mapIt(it.strip.splitWhitespace)
let data = readData("input2.txt")
var s = initSpreadsheet(data)
s.sortEachRow()
echo s
echo s.checksum0()
# echo s.checksum()
