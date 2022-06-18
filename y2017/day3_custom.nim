
type
   Point = object
      x, y: int

   Spiral = object
      position, direction: Point

   Shape = object
      stride, bound: int

   Grid = object
      shape: Shape
      storage: seq[int]

# ---------------
# Helper routines
# ---------------

proc `+`(a, b: Point): Point =
   result = Point(x: a.x + b.x, y: a.y + b.y)

proc `+=`(a: var Point, b: Point) =
   a.x += b.x
   a.y += b.y

proc point(x, y: int): Point =
   result = Point(x: x, y: y)

proc initSpiral(): Spiral =
   result = Spiral(position: point(0, 0),
      direction: point(1, 0))

proc initShape(stride, bound: int): Shape =
   result = Shape(stride: stride, bound: bound)

proc ravel(p: Point; s: Shape): int =
   # Converts a coordinate to a flat (linear) index.
   result = (p.y + s.bound) * s.stride + p.x + s.bound

proc contains(s: Shape; p: Point): bool =
   # Checks if the Point can fit in a grid of Shape s.
   result = max(abs(p.x), abs(p.y)) <= s.bound

proc enlarge(g: var Grid; growthFactor = 2) =
   let old = g.shape
   let bound = old.bound * growthFactor
   let stride = bound * 2 + 1
   g.shape = initShape(stride, bound)
   var n = newSeq[int](stride * stride)
   swap(g.storage, n)
   for i in 0 ..< n.len:
      let x = i mod old.stride - old.bound
      let y = i div old.stride - old.bound
      let p = point(x, y)
      g.storage[ravel(p, g.shape)] = n[i]

proc `[]`(g: Grid; p: Point): int =
   # Assumes the Point is in the grid, otherwise an outlier
   # may get a value stored for another Point.
   let flat = ravel(p, g.shape)
   result = g.storage[flat]

proc `[]=`(g: var Grid; p: Point; value: int) =
   if not contains(g.shape, p): enlarge(g)
   let flat = ravel(p, g.shape)
   g.storage[flat] = value

proc initGrid(initial = 3): Grid =
   # Initial is the maximum horizontal and vertical distance
   # of a Point from the (square) Grid. Its negative number
   # is the array's base index.
   let stride = initial * 2 + 1
   result = Grid(shape: initShape(stride, initial),
      storage: newSeq[int](stride * stride))

proc print(g: Grid; p: Point) =
   let bound = max(abs(p.x), abs(p.y))
   # Top-down iteration to display the Grid properly.
   for j in countdown(bound, -bound):
      var buffer: string
      for i in countup(-bound, bound):
         if buffer.len > 0:
            buffer.add('\t')
         let p = point(i, j)
         buffer.add($g[p])
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
      point(-1, -1),
      point(-1, 0),
      point(-1, 1),
      point(0, -1),
      point(0, 1),
      point(1, -1),
      point(1, 0),
      point(1, 1)]
   for d in directions:
      let adjacent = p + d
      if adjacent in g.shape:
         result += g[adjacent]

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
      g[s.position] = value
      next(s)
      value = g.sumAdjacents(s.position)
   g.print(s.position)
   result = value

# -------------
# Batch Program
# -------------

let input = 347991
echo solvePart1(input) # 480
echo solvePart2(input) # 349975
