import readline from 'readline';

type YX = [number, number];

const stdin = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const is_wall = (map: string[], [y, x]: YX): boolean => {
    return map[y][x] === '#';
}

const is_in_bounds = (map: string[], [y, x]: YX): boolean => {
    return y >= 0 && y < map.length && x >= 0 && x < map[y].length;
}

const is_same_point = ([y1, x1]: YX, [y2, x2]: YX): boolean => {
    return y1 === y2 && x1 === x2;
}

const get_neighbors = (map: string[], [y, x]: YX): YX[] => {
    let result: YX[] = [];
    const candidates = [
        [y - 1, x],
        [y + 1, x],
        [y, x - 1],
        [y, x + 1]
    ];
    for (const [ny, nx] of candidates) {
        if (is_in_bounds(map, [ny, nx])) {
            result.push([ny, nx]);
        }
    }
    return result;
}

const find_shortcuts = (map: string[], d_from_start: number[][], d_from_end: number[][], d_max: number, p0: YX): [YX, YX, number][] => {
    if (is_wall(map, p0)) {
        return [];
    }

    let shortcuts: [YX, YX, number][] = [];

    for (let p1 of get_neighbors(map, p0)) {
        for (let p2 of get_neighbors(map, p1)) {
            if (is_wall(map, p2)) {
                continue;
            }

            // Check if start -> p0 -> p1 (+1) -> p2 (+1) -> end is shorter than p0 -> end
            let d_with_shortcut = d_from_start[p0[0]][p0[1]] + 2 + d_from_end[p2[0]][p2[1]];
            let d_without_shortcut = d_from_start[p0[0]][p0[1]] + d_from_end[p0[0]][p0[1]];

            if (d_with_shortcut <= d_max) {
                shortcuts.push([p0, p2, d_with_shortcut]);
            }
        }

    }
    return shortcuts;
}


const find_shortest_paths_without_cheating = (map: string[], start: YX): number[][] => {
    let result: number[][] = Array.from({ length: map.length }, () => Array(map[0].length).fill(-1));


    result[start[0]][start[1]] = 0;
    let queue: [YX, number][] = [[start, 0]];
    while (queue.length > 0) {
        // Pop the first element
        let [p, d] = queue.shift()!;

        for (const new_p of get_neighbors(map, p).filter(p => !is_wall(map, p))) {
            let new_d = d + 1;

            // If already reached this point with a shorter distance, skip
            if (result[new_p[0]][new_p[1]] >= 0 && result[new_p[0]][new_p[1]] <= new_d) {
                continue;
            }

            // New shortest path found
            result[new_p[0]][new_p[1]] = new_d;

            // Add to the queue
            queue.push([new_p, new_d]);
        }
    }

    return result;
}

const main = async () => {
    let start: YX = [0, 0];
    let end: YX = [0, 0];
    let map: string[] = [];
    for await (const line of stdin) {
        map.push(line);

        const startIdx = line.indexOf('S');
        if (startIdx !== -1) {
            start = [map.length - 1, startIdx];
        }
        const endIdx = line.indexOf('E');
        if (endIdx !== -1) {
            end = [map.length - 1, endIdx];
        }
    }
    stdin.close();

    const d_from_start = find_shortest_paths_without_cheating(map, start);
    const d_from_end = find_shortest_paths_without_cheating(map, end);
    const d_shortest_without_shortcut = d_from_end[start[0]][start[1]];
    const d_min_saved = 100;

    let unique_shortcuts: [YX, YX, number][] = [];
    for (let y = 0; y < map.length; y++) {
        for (let x = 0; x < map[y].length; x++) {
            const p: YX = [y, x];
            if (!is_wall(map, p)) {
                const new_shortcuts = find_shortcuts(map, d_from_start, d_from_end, d_shortest_without_shortcut - d_min_saved, p);
                unique_shortcuts.push(...new_shortcuts.filter(([p1, p2]) =>
                    !unique_shortcuts.some(([pa, pb]) => is_same_point(p1, pa) && is_same_point(p2, pb))
                ));
            }
        }
    }

    console.log(`The answer is: ${unique_shortcuts.length}`);
}

main();
