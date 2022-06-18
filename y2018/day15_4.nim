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

proc contains(m: Map; p: Point): bool =
   # Checks if the Point can fit in a grid of Shape s.
   result = 0 <= p.x and p.x <= m.width and 0 <= p.y and p.y <= m.height

proc isPassable(p: Point, m: Map): bool =
   result = id notin m.walls

proc neighbors(p: Point, m: Map): seq[Point] =
   # @[(x - 1, y), (x, y - 1), (x, y + 1), (x + 1, y)]
   const directions = [
      point(0, -1),
      point(-1, 0),
      point(1, 0),
      point(0, 1)]
   for d in directions:
      let adjacent = p + d
      if adjacent in m and isPassable(adjacent, m):
         result.add adjacent

proc print(g: Game) =
   proc unitPos(units: seq[Unit], p: Point): int =
      result = -1
      for (i, u) in units.pairs:
         if u.position == p:
            return i

   for j in 0 ..< g.map.height:
      var buffer: string
      var unitsInLine: seq[Unit]
      for i in 0 ..< g.map.width:
         let p = point(i, j)
         let f = unitPos(g.units, p)
         if f >= 0:
            buffer.add($g.units[f].race)
            unitsInLine.add(g.units[f])
         else:
            buffer.add($g.map[p])
      if unitsInLine.len > 0:
         var isFirst = true
         for u in unitsInLine.items:
            if isFirst:
               buffer.add("   ")
               isFirst = false
            else:
               buffer.add(", ")
            buffer.addf("$1($2)", u.race, u.health)
      echo(buffer)


proc print(g: Game) =
   for j in 0 ..< g.map.height:
      var buffer: string
      var unitsInLine: seq[Unit]
      for i in 0 ..< g.map.width:
         let p = point(i, j)
         var found = false
         for u in g.units.items:
            if u.position == p:
               buffer.add($u.race)
               unitsInLine.add(u)
               found = true
               break
         if not found:
            buffer.add($g.map[p])
      if unitsInLine.len > 0:
         var first = true
         for u in unitsInLine.items:
            if first:
               buffer.add("   ")
               first = false
            else:
               buffer.add(", ")
            buffer.addf("$1($2)", u.race, u.health)
      echo(buffer)
