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
start_direction = EAST
for y, line in enumerate(sys.stdin.readlines()):
    line = line.strip()
    map.append(line)
    for x, char in enumerate(line):
        if char == 'S':
            start_pos = (x, y)

expected_path_length = 7036  # Real value censored!


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

    # Turn
    if dir == NORTH or dir == SOUTH:
        yield pos, WEST, score + 1000, False
        yield pos, EAST, score + 1000, False
    else:
        yield pos, NORTH, score + 1000, False
        yield pos, SOUTH, score + 1000, False


def find_positions_on_any_shortest_path(map, p0, d0) -> int:
    shortest_known_path_by_position_and_dir = {
        (p0, d0): 0
    }
    shortest_paths: List[List[State]] = []
    heads: List[List[State]] = [[(p0, d0, 0, False)]]

    while heads:
        heads.sort(key=lambda p: p[-1][2])
        path = heads.pop()
        state = path[-1]

        new_steps: List[State] = []
        for new_state in get_candidate_moves(map, state):
            pos, dir, score, done = new_state

            if score > expected_path_length:
                break

            if done:
                new_steps.clear()
                shortest_paths.append(path + [new_state])
                break

            last_shortest = shortest_known_path_by_position_and_dir.get((pos, dir), None)
            if last_shortest is None or score <= last_shortest:
                shortest_known_path_by_position_and_dir[(pos, dir)] = score
                new_steps.append(new_state)

        if len(new_steps) == 1:
            path.append(new_steps[0])
            heads.append(path)
        elif len(new_steps) >= 2:
            for new_step in new_steps:
                heads.append(path + [new_step])

    positions_on_any_shortest_path = set()
    for path in shortest_paths:
        for p, _, _, _ in path:
            positions_on_any_shortest_path.add(p)

    return len(positions_on_any_shortest_path)


print(f"The answer is: {find_positions_on_any_shortest_path(map, start_pos, start_direction)}")
