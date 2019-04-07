import hashes, tables

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
   result = Point(x: x, y: y)

proc initSpiral(): Spiral =
   result = Spiral(position: initPoint(0, 0), direction: initPoint(1, 0))

proc initGrid(): Grid =
   result = Grid(storage: initTable[Point, int]())

proc print(g: Grid; p: Point) =
   let side = max(abs(p.x), abs(p.y))
   # Top-down iteration to display the Grid properly.
   for j in countdown(side, -side):
      var buffer: string
      for i in countup(-side, side):
         if buffer.len > 0:
            buffer.add('\t')
         let p = initPoint(i, j)
         var v = 0
         if p in g.storage:
            v = g.storage[p]
         buffer.add($v)
      echo(buffer)

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
   const directions = [
      initPoint(-1, -1),
      initPoint(-1, 0),
      initPoint(-1, 1),
      initPoint(0, -1),
      initPoint(0, 1),
      initPoint(1, -1),
      initPoint(1, 0),
      initPoint(1, 1)]
   for d in directions:
      let adjacent = p + d
      if contains in g.storage:
         result += g.storage[adjacent]

proc solvePart1(number: int): Natural =
   # Distance of Point whose value is given, from the origin.
   var s = initSpiral()
   var value = 1
   while value < number:
      next(s)
      value.inc
   result = abs(s.position.x) + abs(s.position.y)

proc solvePart2(number: int): Natural =
   # First value written that is larger than the input.
   var s = initSpiral()
   var g = initGrid()
   var value = 1
   while value < number:
      g.storage[s.position] = value
      next(s)
      value = g.sumAdjacents(s.position)
   g.print(s.position)
   result = value

# -------------
# Batch Program
# -------------

let input = 347991
echo solvePart1(input)
echo solvePart2(input)
