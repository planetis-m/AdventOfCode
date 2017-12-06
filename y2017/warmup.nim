import sets, hashes, strutils

type
   Point = object
      x, y: int

   Grid = object
      origin: Point
      markersA: HashSet[Point]
      markersB: HashSet[Point]

proc hash(p: Point): Hash =
   result = hash(p.x) !& hash(p.y)
   result = !$result

template registerPoint(markers): untyped =
   let currentPos = Point(x: x, y: y)
   markers.incl(currentPos)

proc createGrid(input: string): Grid =
   result.markersA = initSet[Point]()
   result.markersB = initSet[Point]()
   var x, y = 0
   for command in split(input, ", "):
      case command
      of "Up":
         inc y
      of "Down":
         dec y
      of "Left":
         dec x
      of "Right":
         inc x
      of "A":
         registerPoint(result.markersA)
      of "B":
         registerPoint(result.markersB)
      of "Start":
         return

template maxDistanceImpl(a, b: typed): untyped =
   let dist = abs(b.x - a.x) + abs(b.y - a.y)
   if dist > result: result = dist

proc maxDistanceFromOrigin(g: Grid): int =
   for point in g.markersA:
      maxDistanceImpl(point, g.origin)
   for point in g.markersB:
      maxDistanceImpl(point, g.origin)

proc maxDistanceBetweenPoints(g: Grid): int =
   for pointA in g.markersA:
      for pointB in g.markersB:
         maxDistanceImpl(pointB, pointA)

var g = createGrid(readFile("codes.txt"))
echo maxDistanceFromOrigin(g)
echo maxDistanceBetweenPoints(g)
