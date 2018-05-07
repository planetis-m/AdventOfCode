import algorithm, combinatorics, parseutils

type Spreadsheet = seq[seq[int]]

proc readSpreadsheet(s: string): Spreadsheet =
   var i = 0
   while i < len(s):
      var row: seq[int]
      while s[i] != '\l':
         var d: int
         if s[i] in {'0' .. '9'}:
            i.inc parseInt(s, d, i)
            row.add d
         while s[i] == '\t': i.inc
      result.add row
      i.inc

proc sortEachRow(s: var Spreadsheet) =
   for row in mitems(s):
      sort(row, system.cmp)

template notSortedRows(s) =
   assert isSorted(s[0], system.cmp)

proc checksum0(s: Spreadsheet): int =
   notSortedRows(s)
   for row in s:
      result += row[^1] - row[0]

proc checksum(s: Spreadsheet): int =
   notSortedRows(s)
   for row in s:
      var d = 0
      for p in combinations(row, 2):
         if p[1] mod p[0] == 0:
            d = p[1] div p[0]
      result += d

var s = readSpreadsheet(readFile("input2.txt"))
s.sortEachRow()
echo s.checksum0()
echo s.checksum()
