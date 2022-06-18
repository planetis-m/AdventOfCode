import algorithm, hashes, tables, sets, deques, strutils

type
  Tile = enum
    Wall = "#", Cavern = "."

  Race = enum
    Elf = "E", Goblin = "G"

  Point = object
    x, y: int

  Unit = object
    race: Race
    position: Point
    health, attack: int

  Map = object
    width, height: int # map dimensions
    tiles: seq[Tile]   # flat storage of map

  Game = object
    map: Map
    units: seq[Unit]
    rounds: int
    isOver: bool

# ---------------
# Helper routines
# ---------------

proc hash(p: Point): Hash =
  result = hash(p.x) !& hash(p.y)
  result = !$result

proc `+`(a, b: Point): Point =
  result = Point(x: a.x + b.x, y: a.y + b.y)

proc `+=`(a: var Point; b: Point) =
  a.x += b.x
  a.y += b.y

proc `-`(a, b: Point): Point =
  result = Point(x: a.x - b.x, y: a.y - b.y)

proc `==`(a, b: Point): bool =
  result = a.y == b.y and a.x == b.x

proc `<`(a, b: Point): bool =
  # compares in reading order
  result = a.y < b.y or (a.y == b.y and a.x < b.x)

proc cmp(a, b: Point): int =
  # compares in reading order
  result = if a.y == b.y: a.x - b.x else: a.y - b.y
   # ravel(a, width) - ravel(a, width)

proc point(x, y: int): Point =
  result = Point(x: x, y: y)

proc dist(a, b: Point): int =
  # calculates the manhattan distance
  result = abs(b.x - a.x) + abs(b.y - a.y)

proc ravel(p: Point; m: Map): int =
  # Converts a coordinate to a flat (linear) index.
  result = p.y * m.width + p.x

proc `[]`(m: Map; p: Point): Tile =
  # Assumes the Point is in the grid, otherwise an outlier
  # may get a value stored for another Point.
  let flat = ravel(p, m)
  result = m.tiles[flat]

proc `[]=`(m: var Map; p: Point; t: Tile) =
  # Assumes the Point is in the grid, otherwise an outlier
  # may get a value stored for another Point.
  let flat = ravel(p, m)
  m.tiles[flat] = t

proc contains(m: Map; p: Point): bool =
  # Checks if the Point can fit in a grid of Shape s.
  result = p.x <= m.width and p.y <= m.height

proc `==`(a, b: Unit): bool =
  result = a.position == b.position

proc `<`(a, b: Unit): bool =
  result = a.position < b.position

proc cmp(a, b: Unit): int =
  result = cmp(a.position, b.position)

proc isEnemy(a, b: Unit): bool =
  result = a.race != b.race

proc isPassable(p: Point; m: Map): bool =
  # Does not perform bound checks as it takes advantage the fact that
  # input puzzles have borders limited by walls.
  m[p] == Cavern

iterator neighbors(p: Point; m: Map): Point =
  const directions = [
     point(0, -1),
     point(-1, 0),
     point(1, 0),
     point(0, 1)]
  for d in directions:
    let adjacent = p + d
    if adjacent in m and isPassable(adjacent, m):
      yield adjacent

proc initGame(input: string; elvesAttackPower: Positive): Game =
  var tiles: seq[Tile]
  var units: seq[Unit]
  var x, y: int
  for line in splitLines(input):
    x = 0
    for c in line.items:
      case c
      of '#':
        tiles.add Wall
      of '.':
        tiles.add Cavern
      of 'E':
        units.add Unit(position: point(x, y), health: 200,
              attack: elvesAttackPower, race: Elf)
        tiles.add Cavern
      of 'G':
        units.add Unit(position: point(x, y), health: 200,
              attack: 3, race: Goblin)
        tiles.add Cavern
      else:
        discard
      x.inc
    y.inc
  result = Game(units: units,
     map: Map(tiles: tiles, width: x, height: y))

proc print(g: Game) =
  proc find(units: seq[Unit]; p: Point): int =
    result = -1
    for i in 0 ..< units.len:
      if units[i].position == p:
        return i
  template `?=`(name, call): bool = (let name = call; name != -1)

  for j in 0 ..< g.map.height:
    var buffer: string
    var unitsInLine: seq[Unit]
    for i in 0 ..< g.map.width:
      let p = point(i, j)
      if f ?= find(g.units, p):
        template unit: untyped = g.units[f]

        buffer.add($unit.race)
        unitsInLine.add(unit)
      else:
        buffer.add($g.map[p])
    var isFirst = true
    for u in unitsInLine.items:
      if isFirst:
        buffer.add("   ")
        isFirst = false
      else:
        buffer.add(", ")
      buffer.addf("$1($2)", u.race, u.health)
    echo(buffer)

proc bfSearch(m: Map; start: Point; goals: HashSet[Point]): (Table[Point,
      Point], Point) =
  var frontier: Deque[Point]
  frontier.addLast(start)
  var cameFrom: Table[Point, Point]
  cameFrom[start] = point(-1, -1)

  var current: Point
  while frontier.len > 0:
    current = frontier.popFirst()
    if current in goals:
      break

    for next in neighbors(current, m):
      if next notin cameFrom:
        frontier.addLast(next)
        cameFrom[next] = current
  result = (cameFrom, current)

proc main =
  var input = readFile("data/input15_1.txt")
  input.stripLineEnd
  var g = initGame(input, 3)
  # g.units.sort((a, b) => cmp(a.position, b.position, g.width))
  g.units.sort(cmp)
  print(g)

main()

# proc reversePath[N](parents: seq[int]; parent: int -> int;
#       start: int): seq[int] =
#    result = collect(newSeq):
#       var i = start
#       while i < parents.len:
#          let node = i
#          let value = parents[i]
#          i = parent(value)
#          node
#    result.reverse()
#
# proc bfs(size: int, start: int; successors: int -> seq[int]; success: int -> bool;
#       checkFirst = true): seq[int] =
#    if checkFirst and success(start):
#       result.add(start)
#       return
#    var toSee = initDeque[int]()
#    var parents = newSeq[int](size)
#    parents[start] = high(int)
#    toSee.addLast(start)
#    while toSee.len > 0:
#       let node = toSee.popFirst()
#       for successor in successors(node):
#          if success(successor):
#             result = reversePath(parents, p => p, node)
#             result.add(successor)
#             return
#          if successor notin parents:
#             parents[successor] = node
#             toSee.addLast(successor)
#    # just return an empty path
#
# proc (): bool =
#    let a = g.map[p]
#    for n in g.neighbors(p):
#       let b = g.map[n]
#       if a.isEnemy(b):
#          return true

# bfs(g.tiles.len, start, neighbors, p)

# import heapqueue, sets
# # return the shortest path from source to any of the targets
# # in the case of a tie, return all shortest paths
# proc shortestPaths(source: , targets, occupied: Has): seq[] =
#    var best = 0
#    var visited = toHashSet(occupied)
#    var queue: HeapQueue[(int, seq[])]
#    queue.push((0, @[source]))
#    while queue.len > 0:
#       distance, path = queue.pop()
#       if best and len(path) > best:
#          break
#       node = path[^1]
#       if node in targets:
#          result.add(path)
#          best = len(path)
#       elif node notin visited:
#          visited.add(node)
#          for neighbor in adjacent({node}):
#             if neighbor notin visited:
#                path.add neighbor
#                queue.push((distance + 1, path + [neighbor]))
#
# # adjacent returns all cells that are adjacent to all of the provided positions
# proc adjacent(positions):
#    return set((y + dy, x + dx)
#       for y, x in positions
#          for dy, dx in [(-1, 0), (0, -1), (0, 1), (1, 0)])

