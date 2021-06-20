import json

const directions: array[4, string] = ["up", "down", "left", "right"]

type
  Point = ref object of RootObj
    x, y: int

proc `x=`*(p: var Point, value: int) {.inline.} =
  p.x = value

proc `y=`*(p: var Point, value: int) {.inline.} =
  p.y = value

proc isEqual(point: Point, target: Point): bool =
  return (point.x == target.x) and (point.y == target.y)

proc move(point: Point, direction: int): Point =
  case directions[direction]:
    of "up":
      return Point(x: point.x, y: point.y - 1)
    of "down":
      return Point(x: point.x, y: point.y + 1)
    of "left":
      return Point(x: point.x - 1, y: point.y)
    of "right":
      return Point(x: point.x + 1, y: point.y)

type
  Block = ref object of RootObj
    isWall: bool
    traversed: int

proc `isWall=`*(b: var Block, value: bool) {.inline.} =
  b.isWall = value

proc `traversed=`*(b: var Block, value: int) {.inline.} =
  b.traversed = value

type
  Maze = ref object of RootObj
    start: Point
    `end`: Point
    current: Point
    last: Point
    direction: int
    maze: seq[seq[Block]]

proc `start=`*(m: var Maze, value: Point) {.inline.} =
  m.start = value

proc `end=`*(m: var Maze, value: Point) {.inline.} =
  m.`end` = value

proc `current=`*(m: var Maze, value: Point) {.inline.} =
  m.current = value

proc `last=`*(m: var Maze, value: Point) {.inline.} =
  m.last = value

proc `direction=`*(m: var Maze, value: int) {.inline.} =
  m.direction = value

proc `maze=`*(m: var Maze, value: seq[seq[Block]]) {.inline.} =
  m.maze = value

proc getBlock(maze: Maze, coords: Point): Block =
  return maze.maze[coords.x][coords.y]

proc move(m: Maze, trackingBack: bool): bool =
  let next = m.current.move(m.direction)
  let nextBlock = m.getBlock(next)

  if (trackingBack or nextBlock.traversed == 0):
    if (not nextBlock.isWall and nextBlock.traversed < 2):
      m.last = m.current
      m.current = next

      var currentBlock = m.getBlock(m.current)
      currentBlock.traversed += 1
      m.maze[m.current.x][m.current.y] = currentBlock

      var lastBlock = m.getBlock(m.last)
      if trackingBack:
        lastBlock.traversed = 2
        m.maze[m.last.x][m.last.y] = lastBlock
      if (currentBlock.traversed == 1 and lastBlock.traversed == 2):
        lastBlock.traversed = 1
        m.maze[m.last.x][m.last.y] = lastBlock
      return true
  else:
    return false

proc tremaux(m: Maze): Maze =
  while (not m.`end`.isEqual(m.current)):
    let originalDirection = m.direction
    while (not m.move(false)):
      m.direction = (m.direction + 1) mod directions.len
      if (m.direction == originalDirection):
        while (not m.move(true)):
          m.direction = (m.direction + 1) mod directions.len
        break
  return m

proc buildMaze(filename: string): Maze =
  let mazeJson = parseFile(filename)

  let start = to(mazeJson["start"], Point)
  let `end` = to(mazeJson["end"], Point)
  let mazeData = mazeJson["maze"]

  var m: seq[seq[Block]] = @[]
  for row in mazeData:
    var r: seq[Block] = @[]
    for col in row:
      let isWall: bool = col.getBool()
      let b = Block(isWall: isWall, traversed: 0)
      r.add(b)
    m.add(r)

  return Maze(start: start,
              `end`: `end`,
              current: start,
              last: Point(x: -1, y: -1),
              direction: 0,
              maze: m)
