import algorithm, hashes, tables, strutils

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
   assert isSorted(g.units, cmp)
   var units = g.units
   for j in 0 ..< g.map.height:
      var buffer: string
      for i in 0 ..< g.map.width:
         let p = point(i, j)
         let f = binarySearch(units, Unit(position: p), cmp)
         if f != -1:
            buffer.add $units[f].race
            delete(units, f)
         else:
            buffer.add($g.map[p])
      echo(buffer)

proc isAccessible(p: Point; g: Game): bool =
   # Does not perform bound checks as it takes advantage the fact that
   # input puzzles have borders limited by walls.
   g.map[p] == Cavern

iterator neighbors(g: Game; p: Point): Point =
   const directions = [
      point(0, -1),
      point(-1, 0),
      point(1, 0),
      point(0, 1)]
   for d in directions:
      let adjacent = p + d
      if isAccessible(adjacent, g):
         yield adjacent

proc main =
   var input = readFile("data/input15_1.txt")
   input.stripLineEnd
   var g = initGame(input, 3)
   # g.units.sort((a, b) => cmp(a.position, b.position, g.width))
   g.units.sort(cmp)
   g.print()

main()
#
# type
#    TileMode = enum
#       occupied, open, unpassable
#
# proc cmp(a, b: Unit): int =
#    a.pos - b.pos
#
# proc initGame(input: string; elvesAttackPower: Natural): Game =
#    var tiles: seq[Tile]
#    var units: seq[Unit]
#    var count, width: int
#    for line in splitLines(input):
#       width = 0
#       for c in line:
#          case c
#          of '#':
#             tiles.add Wall
#          of '.':
#             tiles.add Cavern
#          of 'E':
#             units.add Unit(position: count, health: 200,
#                   attack: elvesAttackPower, race: Elf)
#             tiles.add Elf
#          of 'G':
#             units.add Unit(position: count, health: 200, attack: 3, race: Goblin)
#             tiles.add Goblin
#          else:
#             discard
#          width.inc
#          count.inc
#    result = Game(tiles: tiles, units: units, width: width, height: if width >
#          0: count div width else: 0)
#
# iterator neighbors(g: Game; p: Point): Point =
#    let directions = [-g.width, g.width, -1, 1] # Up/Down/Left/Right
#    for d in directions:
#       let adjacent = p + d
#       if isAccessible(adjacent, g):
#          yield adjacent
#
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
# bfs(g.tiles.len, start, neighbors, p => g.tiles[p] != Elf)

