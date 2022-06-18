import sugar, algorithm, strutils

proc validCoord(dss: seq[seq[int]], y, x: int): bool =
   if y >= 0 and y < len(dss):
      if x >= 0 and x < len(dss[y]):
         return true
   result = false

type
   Mob = object
      x, y: int
      isElf: bool
      health: int

var world: seq[seq[char]]
var mobs: seq[Mob]

proc initMob(x, y: int, isElf: bool): Mob =
   result.x = x
   result.y = y
   result.isElf = isElf
   result.health = 200

proc getAttacked(self: var Mob) =
   self.health -= 3
   if self.health <= 0:
      self.health = 0

# order is important, reverse reading order
const neighbours = [(0, -1), (-1, 0), (1, 0), (0, 1)]

proc hasEnemies(self: Mob): bool =
   # Are there mobs of the other sort?
   let activeMobs = collect(newSeq, for m in mobs: (if m.health > 0: m))
   let enemies = collect(newSeq, for m in activeMobs: (if m.isElf != self.isElf: m))
   result = len(enemies) > 0

proc act(self: var Mob) =
   # Find active mobs
   let activeMobs = collect(newSeq, for m in mobs: (if m.health > 0: m))
   let enemies = collect(newSeq, for m in activeMobs: (if m.isElf != self.isElf: m))

   if len(enemies) == 0:
      return

   # Map up the world as -1 (wall) or -2 (space)
   var distances: seq[seq[int]]
   for row in world:
      var ds: seq[int]
      for col in row:
         let dist = if col == '#': -1 else: -2
         ds.add(dist)
      distances.add(ds)

   # All mobs apart from self is marked as well
   for m in activeMobs:
      if m != self:
         distances[m.y][m.x] = -1

   # For all enemies, map non-wall neighbours as zero (distance to enemy)
   for m in enemies:
      if m.isElf != self.isElf:
         for (nx, ny) in neighbours.items:
            let cx = m.x + nx
            let cy = m.y + ny
            if validCoord(distances, cy, cx):
               if distances[cy][cx] == -2:
                  distances[cy][cx] = 0

   # We are not next to an enemy, let's move towards one
   if not distances[self.y][self.x] == 0:
      var updated = true
      while updated:
         updated = false
         for y in 0 ..< len(distances):
            for x in 0 ..< len(distances[y]):
               if distances[y][x] >= 0:
                  var foundPath = false
                  for (nx, ny) in neighbours.items:
                     let cx = x + nx
                     let cy = y + ny
                     if validCoord(distances, cy, cx):
                        if distances[cy][cx] == -2 or distances[cy][cx] > distances[y][x]+1:
                           distances[cy][cx] = distances[y][x]+1
                           foundPath = true
                           updated = true

      #echo "===>", self.x, self.y, self.isElf
      #for ds in distances:
         #var t = ""
         #for d in ds:
            #t.add " " & $d
         #echo t

      var tx = -1
      var ty = -1
      var best = -1
      for (nx, ny) in neighbours.items:
         if validCoord(distances, self.y+ny, self.x+nx):
            if distances[self.y+ny][self.x+nx] >= 0 and (best == -1 or distances[self.y+ny][self.x+nx] < best):
               tx = self.x+nx
               ty = self.y+ny
               best = distances[self.y+ny][self.x+nx]

      # We have somewhere to move
      if not best == -1:
         self.x = tx
         self.y = ty

      # For all enemies, map non-wall neighbours as zero (distance to enemy) - updates if we are in range
      for m in enemies:
         if m.isElf != self.isElf:
            for (nx, ny) in neighbours.items:
               let cx = m.x+nx
               let cy = m.y+ny
               if validCoord(distances, cy, cx):
                  if distances[cy][cx] == -2:
                     distances[cy][cx] = 0

      # We are next to at least one enemy, attach the closest in reading order
      if distances[self.y][self.x] == 0:
         var eligable = collect(newSeq):
            for (nx, ny) in neighbours.items:
               for m in enemies:
                  if m.x == self.x+nx and m.y == self.y+ny:
                     m
         eligable.sort((a, b) => (a.health<b.health or a.y<b.y or a.x<b.x))
         eligable[0].getAttacked()

proc printWorld() =
   for y in 0 ..< len(world):
      var r = ""
      for x in 0 ..< len(world[y]):
         var c = world[y][x]
         for m in mobs:
            if m.x == x and m.y == y:
               if m.isElf:
                  c = 'E'
               else:
                  c = 'G'
         r.add c
      var ri = ""
      for m in mobs:
         if m.y == y:
            if ri.len > 0: r.add ", "
            var t = if m.isElf: "E(" else: "G("
            t.add $m.health
            t.add ")"
            ri.add(t)
      echo r, "   ", ri

var input = readFile("data/input15_1.txt")
input.stripLineEnd
var x, y: int
for line in splitLines(input):
   x = 0
   var l: seq[char]
   for c in line:
      case c
      of '#':
         l.add '#'
      of '.':
         l.add '.'
      of 'E':
         mobs.add initMob(x, y, true)
         l.add '.'
      of 'G':
         mobs.add initMob(x, y, false)
         l.add '.'
      else:
         discard
      world.add l
      x.inc
   y.inc

# fight iteration
var fighting = true
var activeRound = false
var g = 0
while fighting:
#    print "Iteration:", g
#    print_world()
   mobs.sort((a, b) => (a.y<b.y or a.x<b.x))

   # has enemies?
   activeRound = false
   for m in mobs.mitems:
      let canFight = m.hasEnemies()
      fighting = fighting and canFight
      activeRound = activeRound or canFight
      if m.health > 0:
         m.act()

   mobs = collect(newSeq, for m in mobs: (if m.health > 0: m))
   g.inc
g.dec

echo "Outcome"
printWorld()

var s = 0
for m in mobs:
   s += m.health

echo "Result: ", s*g, "(", s, "*", g, ")"
