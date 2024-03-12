import std/[algorithm, packedsets, deques, strutils, syncio]

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
    width, height: int # Map dimensions
    tiles: seq[Tile]   # Flat storage of map

  Game = object
    map: Map
    units: seq[Unit]
    rounds: int
    isOver: bool

# ---------------
# Helper routines
# ---------------

template `?=`(name: untyped, call: typed): bool = (let name = call; name != -1)

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

proc isAlive(x: Unit): bool =
  result = x.health > 0

proc isPassable(p: Point; m: Map): bool =
  # Does not perform bound checks as it takes advantage the fact that
  # input puzzles have borders limited by walls.
  m[p] == Cavern

iterator neighbors(p: Point; m: Map): Point =
  const
    directions = [
      point(0, -1),
      point(-1, 0),
      point(1, 0),
      point(0, 1)
    ]
  for d in directions:
    let adjacent = p + d
    if adjacent in m and isPassable(adjacent, m):
      yield adjacent

proc initGame(input: string; elvesAttackPower: Positive): Game =
  var tiles: seq[Tile] = @[]
  var units: seq[Unit] = @[]
  var x, y = 0
  for line in splitLines(input):
    x = 0
    for c in line.items:
      case c
      of '#':
        tiles.add Wall
      of '.':
        tiles.add Cavern
      of 'E':
        units.add Unit(
          position: point(x, y), health: 200,
          attack: elvesAttackPower, race: Elf
        )
        tiles.add Cavern
      of 'G':
        units.add Unit(
          position: point(x, y), health: 200,
          attack: 3, race: Goblin
        )
        tiles.add Cavern
      else:
        discard
      inc x
    inc y
  result = Game(
    units: units,
    map: Map(tiles: tiles, width: x, height: y)
  )

proc print(g: Game) =
  for j in 0 ..< g.map.height:
    var buffer = ""
    var unitsInLine: seq[Unit] = @[]
    for i in 0 ..< g.map.width:
      let p = point(i, j)
      block outer:
        for unit in g.units.items:
          if unit.position == p:
            buffer.add($unit.race)
            unitsInLine.add(unit)
            break outer
        buffer.add($g.map[p])
    var first = true
    for unit in unitsInLine.items:
      if first:
        buffer.add("   ")
        first = false
      else:
        buffer.add(", ")
      buffer.addf("$1($2)", unit.race, unit.health)
    stdout.write(buffer, '\n')

# proc breadthFirstSearch(graph: Graph; source: NodeIdx): seq[Point] =
#   var queue: Deque[NodeIdx]
#   queue.addLast(source)
#
#   result = @[graph[source]]
#   var visited: PackedSet[NodeIdx]
#   visited.incl source
#
#   while queue.len > 0:
#     let idx = queue.popFirst()
#     template node: untyped = graph.nodes[idx.int]
#     for neighbor in node.edges:
#       if neighbor notin visited:
#         queue.addLast(neighbor)
#         visited.incl neighbor
#         result.add(graph[neighbor])

proc move(g: var Game, u: Unit, elfDeath: bool): bool = discard
  # for unit in items(g.units):
  #   if isEnemy(unit, u):

proc round(g: var Game, elfDeath: bool): bool =
  g.units.sort(cmp)
  for unit in items(g.units):
    if g.move(unit, elfDeath):
      return true

proc play(g: var Game, elfDeath = false): int =
  var round = 0
  while true:
    if g.round(elfDeath):
      break
    for i in countdown(g.units.high, 0):
      if not g.units[i].isAlive:
        del(g.units, i)
    print(g)
    inc round
  var remaining = 0
  for unit in g.units:
    remaining += unit.health
  result = round * remaining

proc createGame(): Game =
  var input = readFile("data/test_input15_7.txt")
  stripLineEnd(input)
  result = initGame(input, 3)

proc main =
  var game = createGame()
  print game
  # game.play()

main()
