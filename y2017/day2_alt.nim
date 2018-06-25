import strutils, algorithm #, combinatorics

type
   Spreadsheet = object
      lens: seq[int]
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
   result.lens = newSeq[int](data.len)
   inner = 0
   var count = 0
   for i, d in data:
      inner += d.len
      result.lens[i] = inner
      for s in d:
         result.data[count] = parseInt(s)
         count.inc

proc row(s: Spreadsheet, i: Natural): seq[int] =
   s.data[if i > 0: s.lens[i - 1] else: 0 ..< s.lens[i]]

iterator rows(s: Spreadsheet): seq[int] =
   var prev = 0
   for i in 0 ..< s.lens.len:
      let curr = s.lens[i]
      yield s.data[prev ..< curr]
      prev = curr

iterator mrows(s: var Spreadsheet): auto =
   var prev = 0
   for i in 0 ..< s.lens.len:
      let curr = s.lens[i]
      yield toOpenArray(s.data, prev, curr - 1)
      prev = curr

proc sortEachRow(s: var Spreadsheet) =
   for r in mrows(s):
      sort(r, cmp)

template notSortedRows(s) =
   assert isSorted(s.row(0), cmp)

proc checksum0(s: Spreadsheet): int =
   notSortedRows(s)
   for r in rows(s):
      result += r[^1] - r[0]

# proc checksum(s: Spreadsheet): int =
#    notSortedRows(s)
#    for r in rows(s):
#       var d = 0
#       for p in combinations(r, 2):
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
