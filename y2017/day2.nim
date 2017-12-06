import algorithm, combinatorics, parseutils

type Spreadsheet = seq[seq[int]]

proc readSpreadsheet(s: string): Spreadsheet =
   result = @[]
   var i = 0
   while i < len(s):
      var row: seq[int] = @[]
      while s[i] != '\l':
         var buf: int
         i.inc parseInt(s, buf, i)
         row.add buf
         while s[i] == '\t': i.inc
      result.add row
      i.inc

proc sortEachRow(sp: var Spreadsheet) =
   for row in mitems(sp):
      sort(row, system.cmp)

template notSortedRows(sp: typed): untyped =
   assert isSorted(sp[0], system.cmp)

proc getChecksum0(sp: Spreadsheet): int =
   notSortedRows(sp)
   for row in sp:
      result += row[row.high] - row[0]

proc getChecksum(sp: Spreadsheet): int =
   notSortedRows(sp)
   for row in sp:
      var res = 0
      for p in combinations(row, 2):
         if p[1] mod p[0] == 0:
            res = p[1] div p[0]
      result += res

var sp = readSpreadsheet(readFile("advent2.txt"))
sp.sortEachRow()
echo sp.getChecksum()
