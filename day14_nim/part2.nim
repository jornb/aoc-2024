import strutils
import sets

const MAP_W = 101
const MAP_H = 103
const NUM_TICKS = 10000

type XY = tuple[x, y: int]

type Robot = object
    pos: XY
    vel: XY

var robots: seq[Robot]

for line in stdin.lines:
    let parts = line.split(" ")
    let p = parts[0].split("=")[1].split(",")
    let v = parts[1].split("=")[1].split(",")

    let x = parseInt(p[0])
    let y = parseInt(p[1])
    let dx = parseInt(v[0])
    let dy = parseInt(v[1])

    robots.add(Robot(pos: (x, y), vel: (dx, dy)))

proc wrap(p: int, max: int): int =
    if p < 0:
        return p + max
    elif p >= max:
        return p - max
    else:
        return p

proc tick() =
    for i in 0 ..< robots.len:
        var r = robots[i]
        r.pos.x = wrap(r.pos.x + r.vel.x, MAP_W)
        r.pos.y = wrap(r.pos.y + r.vel.y, MAP_H)
        robots[i] = r

proc isChristmasTree(): bool =
    var positions = initHashSet[XY]()
    for r in robots:
        if r.pos in positions:
            return false
        positions.incl(r.pos)
    return true

proc printMap() =
    for y in 0 ..< MAP_H:
        for x in 0 ..< MAP_W:
            var found = false
            for r in robots:
                if r.pos.x == x and r.pos.y == y:
                    found = true
                    stdout.write("#")
                    break
            if not found:
                stdout.write(".")
        echo ""
    echo ""

for i in 0 ..< NUM_TICKS:
    tick()

    if isChristmasTree():
        printMap()
        echo "The answer is: ", i + 1
