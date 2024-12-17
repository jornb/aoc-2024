import sys
from typing import List, Tuple, Iterable

Position = Tuple[int, int]
Direction = Tuple[int, int]
State = Tuple[Position, Direction, int, bool]

NORTH: Direction = (0, -1)
SOUTH: Direction = (0, 1)
WEST: Direction = (-1, 0)
EAST: Direction = (1, 0)

map: List[str] = []
start_pos: Position = (0, 0)
end_pos: Position = (0, 0)
start_direction = EAST
for y, line in enumerate(sys.stdin.readlines()):
    line = line.strip()
    map.append(line)
    for x, char in enumerate(line):
        if char == 'S':
            start_pos = (x, y)
        elif char == 'E':
            end_pos = (x, y)


def lookup(map, pos: Position) -> str:
    return map[pos[1]][pos[0]]


def get_candidate_moves(map, state: State) -> Iterable[State]:
    # Move straight
    pos, dir, score, done = state
    straight_ahead_pos = (pos[0] + dir[0], pos[1] + dir[1])
    c = lookup(map, straight_ahead_pos)
    if c == "E":
        yield straight_ahead_pos, dir, score + 1, True
        return
    elif c != "#":
        yield straight_ahead_pos, dir, score + 1, False

    if dir == NORTH or dir == SOUTH:
        yield pos, WEST, score + 1000, False
        yield pos, EAST, score + 1000, False
    else:
        yield pos, NORTH, score + 1000, False
        yield pos, SOUTH, score + 1000, False


def find_shortest_path(map, p0, d0, p1) -> int:
    shortest_known_path_by_position_and_dir = {
        p0: 0
    }
    heads: List[State] = [(p0, d0, 0, False)]

    while heads:
        state = heads.pop()
        for pos, dir, score, done in get_candidate_moves(map, state):
            last_shortest = shortest_known_path_by_position_and_dir.get((pos, dir), None)
            if last_shortest is None or score < last_shortest:
                shortest_known_path_by_position_and_dir[(pos, dir)] = score

                if not done:
                    heads.append((pos, dir, score, done))

    return min(score for (pos, _), score in shortest_known_path_by_position_and_dir.items() if pos == p1)


print(f"The answer is: {find_shortest_path(map, start_pos, start_direction, end_pos)}")
