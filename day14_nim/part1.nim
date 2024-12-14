import strutils

const MAP_W = 101
const MAP_H = 103
const NUM_TICKS = 100

type XY = object
    x: int
    y: int

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

    robots.add(Robot(pos: XY(x: x, y: y), vel: XY(x: dx, y: dy)))

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

for i in 0 ..< NUM_TICKS:
    tick()

var numRobotsInTopLeft = 0
var numRobotsInTopRight = 0
var numRobotsInBottomLeft = 0
var numRobotsInBottomRight = 0

for r in robots:
    var left = r.pos.x < (MAP_W-1) div 2
    var right = r.pos.x >= (MAP_W+1) div 2
    var top = r.pos.y < (MAP_H-1) div 2
    var bot = r.pos.y >= (MAP_H+1) div 2
    if left and top:
        inc numRobotsInTopLeft
    elif right and top:
        inc numRobotsInTopRight
    elif left and bot:
        inc numRobotsInBottomLeft
    elif right and bot:
        inc numRobotsInBottomRight

var answer = numRobotsInTopLeft * numRobotsInTopRight * numRobotsInBottomLeft * numRobotsInBottomRight
echo "The answer is: ", answer
