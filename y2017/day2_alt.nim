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
      result.offsets[i] = inner
      inner += d.len
      for s in d:
         result.data[count] = parseInt(s)
         count.inc

proc sortEachRow(s: var Spreadsheet) =
   for i in 0 ..< s.offsets.len:
      if i + 1 < s.offsets.len:
         sort(toOpenArray(s.data, s.offsets[i], s.offsets[i + 1] - 1), cmp)
      else:
         sort(toOpenArray(s.data, s.offsets[i], s.data.len - 1), cmp)

template notSortedRows(s) =
   assert isSorted(toOpenArray(s.data, 0, s.offsets[1] - 1), cmp)

proc checksum0(s: Spreadsheet): int =
   notSortedRows(s)
   for i in 0 ..< s.offsets.len:
      if i + 1 < s.offsets.len:
         result += s.data[s.offsets[i + 1] - 1] - s.data[s.offsets[i]]
      else:
         result += s.data[s.data.len - 1] - s.data[s.offsets[i]]

# proc checksum(s: Spreadsheet): int =
#    notSortedRows(s)
#    for row in s:
#       var d = 0
#       for p in combinations(row, 2):
#          if p[1] mod p[0] == 0:
#             d = p[1] div p[0]
#       result += d

# let input = "5 1 9 5\n7 5 3\n2 4 6 8\n"
# let data = input.splitLines.mapIt(it.strip.splitWhitespace)
let data = readData("input2.txt")
var s = initSpreadsheet(data)
s.sortEachRow()
echo s.checksum0()
# echo s.checksum()
