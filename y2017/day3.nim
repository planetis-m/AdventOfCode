import hashes, tables, strutils

type
   Point = object
      x, y: int

   Spiral = object
      position: Point
      direction: Point

   Grid = object
      storage: Table[Point, int]

# ---------------
# Helper routines
# ---------------

proc hash(p: Point): Hash =
   result = hash(p.x) !& hash(p.y)
   result = !$result

proc `+`(a, b: Point): Point =
   result.x = a.x + b.x
   result.y = a.y + b.y

proc `+=`(a: var Point; b: Point) =
   a.x += b.x
   a.y += b.y

proc initPoint(x, y: int): Point =
   result.x = x
   result.y = y

proc initSpiral(): Spiral =
   result.position = initPoint(0, 0)
   result.direction = initPoint(1, 0)

proc initGrid(): Grid =
   result.storage = initTable[Point, int]()
   result.storage[initPoint(0, 0)] = 1

proc printGrid(g: Grid; n: int) =
   let s = n div 2
   for j in countdown(s, -s):
      var t: seq[string] = @[]
      for i in countup(-s, s):
         let p = initPoint(i, j)
         var v: int
         if g.storage.hasKey(p):
            v = g.storage[p]
         t.add($v)
      echo(join(t, "\t"))

# ------------
# Program code
# ------------

proc next(s: var Spiral) =
   # The Spiral advances to the next point. It rotates anti-clockwise
   # on the corners except on the 4th quadrant, it moves one step after
   # the corner in order to expand.
   let quadrant4 = s.position.x >= 0 and s.position.y <= 0
   if not quadrant4 and abs(s.position.x) == abs(s.position.y) or
         quadrant4 and s.position.x == 1 - s.position.y:
      let t = s.direction.x
      s.direction.x = -s.direction.y
      s.direction.y = t
   s.position += s.direction

proc sumAdjacents(g: Grid; p: Point): int =
   # Summates the values of the neighboring Points.
   let directions = [
      initPoint(-1, -1),
      initPoint(-1, 0),
      initPoint(-1, 1),
      initPoint(0, -1),
      initPoint(0, 1),
      initPoint(1, -1),
      initPoint(1, 0),
      initPoint(1, 1)
   ]
   for d in directions:
      let adjacent = p + d
      if g.storage.hasKey(adjacent):
         result += g.storage[adjacent]

proc solvePart1(number: int): int =
   # Distance of Point whose value is given, from the origin.
   var s = initSpiral()
   var value = 1
   while value < number:
      next(s)
      inc(value)
   result = abs(s.position.x) + abs(s.position.y)

proc solvePart2(number: int): int =
   # First value written that is larger than the input.
   var s = initSpiral()
   var g = initGrid()
   var value = 1
   while value < number:
      next(s)
      value = g.sumAdjacents(s.position)
      g.storage[s.position] = value
   printGrid(g, 11)
   result = value

let input = 347991
echo solvePart1(input)
echo solvePart2(input)
