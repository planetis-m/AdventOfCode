import sugar, algorithm, strutils, hashes, tables, sets, deques

type
   Pt = tuple
      x, y: int

proc `+`(self, other: Pt): Pt =
   (self.x + other.x, self.y + other.y)

proc nb4(self: Pt): Pt =
   collect(newSeq, for d in items([(0, 1), (1, 0), (0, -1), (-1, 0)]): self + d)

type
   Team = enum
      ELF, GOBLIN

type
   Unit = object
      team: Team
      position: Pt
      hp: int
      alive: bool
      power: int

type ElfDied = object of Exception

type
   Grid = object
      storage: Table[Pt, bool]
      units: seq[Unit]

proc initGrid(lines: seq[string], power=3): Grid =
   for (i, line) in pairs(lines):
      for (j, el) in pairs(line):
         result.storage[(i, j)] = el == '#'
         if el == 'E':
            result.units.add Unit(
               team= Team.ELF,
               position=(i, j),
               hp=200,
               alive=true,
               power=power)
         elif el == 'G':
            result.units.add Unit(
               team=Team.GOBLIN,
               position=(i, j),
               hp=200,
               alive=true,
               power=3)

proc play(self: Grid, elfDeath=false): int =
   var rounds = 0
   while true:
      if self.round(elfDeath=elfDeath):
         break
      rounds.inc
   result = rounds * sum(collect(newSeq, for unit in self.units: (if unit.alive: unit.hp))

proc round(self: Grid, elfDeath=false): bool =
   for unit in sorted(self.units, (a, b) => cmp(a.position, a.position)):
      if unit.alive:
         if self.move(unit, elfDeath=elfDeath):
            return true

proc move(self: Grid, unit: Unit, elfDeath=false): bool =
   let targets = collect(newSeq, for target in self.units: (if unit.team != target.team and target.alive: target))
   let occupied = collect(initHashSet, for u2 in self.units (if u2.alive and unit != u2: {u2.position}))

   if targets.len == 0:
      return true

   let inRange = collect(initHashSet):
      for target in targets:
         for pt in target.position.nb4:
            if not self.storage[pt] and pt notin occupied:
               {pt}

   if unit.position notin inRange:
      let move = self.findMove(unit.position, inRange)
      if move != (0, 0):
         unit.position = move

   let opponents = collect(newSeq, for target in targets: (if target.position in unit.position.nb4: target))

   if opponents.len > 0:
      target = min(opponents, (a, b) => (a.hp<b.hp or a.position<b.position))

      target.hp -= unit.power

      if target.hp <= 0:
         target.alive = false
         if elfDeath and target.team == Team.ELF:
            raise newException(ElfDied)

proc findMove(self: Grid, position: Pt, targets: HashSet[Pt]):
   var visiting = initDeque[(Pt, int)]()
   visiting.addLast((position, 0))
   var meta = {position: (0, (0, 0))}.toTable
   var seen = initHashSet[Pt]()
   var occupied = collect(initHashSet, for unit in self.units: (if unit.alive: {unit.position}))

   while visiting.len > 0:
      let (pos, dist) = visiting.popFirst()
      for nb in pos.nb4:
         if self.storage[nb] or nb in occupied:
            continue
         if nb notin meta or meta[nb] > (dist + 1, pos):
            meta[nb] = (dist + 1, pos)
         if nb in seen:
            continue
         if not any(for visit in visiting: (if nb == visit[0])):
            visiting.addLast((nb, dist + 1))
      seen.incl(pos)

   try:
      let (min_dist, closest) = min(collect(newSeq, for pos, (dist, parent) in meta.items: (if pos in targets: (dist, pos))))
   except ValueError:
      return

   while meta[closest][0] > 1:
      closest = meta[closest][1]

   return closest

let lines = readFile("data/input15_1.txt").splitlines()

var grid = initGrid(lines)

echo("part 1: ", grid.play())

for power in countup(4, 10):
   try:
      outcome = initGrid(lines, power).play(elfDeath=true)
   except ElfDied:
      continue
   else:
      echo("part 2: ", outcome)
      break
