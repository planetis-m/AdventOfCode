import sets, hashes, strutils

type
   Point = object
      x, y: int

   Grid = object
      markersA, markersB: HashSet[Point]

# ---------------
# Helper routines
# ---------------

proc dist(a, b: Point): int =
   result = abs(b.x - a.x) + abs(b.y - a.y)

proc hash(p: Point): Hash =
   result = hash(p.x) !& hash(p.y)
   result = !$result

proc initPoint(x, y: int): Point =
   result.x = x
   result.y = y

proc initGrid(): Grid =
   result.markersA = initSet[Point]()
   result.markersB = initSet[Point]()

# ------------
# Program code
# ------------

proc traverse(g: var Grid; input: string) =
   var cursor = initPoint(0, 0)
   for command in split(input, ", "):
      case command
      of "Up":
         inc(cursor.y)
      of "Down":
         dec(cursor.y)
      of "Left":
         dec(cursor.x)
      of "Right":
         inc(cursor.x)
      of "A":
         g.markersA.incl(cursor)
      of "B":
         g.markersB.incl(cursor)
      of "Start":
         break

proc maxDistanceCenter(g: Grid): int =
   var origin = initPoint(0, 0)
   for p in g.markersA:
      result = max(result, dist(p, origin))
   for p in g.markersB:
      result = max(result, dist(p, origin))

proc maxDistance(g: Grid): int =
   for p in g.markersA:
      # g.markersB.excl(p)
      for r in g.markersB:
         result = max(result, dist(p, r))

# --------------
# Driver Program
# --------------

var g = initGrid()
g.traverse(readFile("input0.txt"))
echo maxDistanceCenter(g)
echo maxDistance(g)
