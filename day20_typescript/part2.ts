import readline from 'readline';

type YX = [number, number];

const stdin = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const is_wall = (map: string[], [y, x]: YX): boolean => {
    return map[y][x] === '#';
}

const find_shortest_paths_without_cheating = (map: string[], start: YX): number[][] => {
    let result: number[][] = Array.from({ length: map.length }, () => Array(map[0].length).fill(-1));

    result[start[0]][start[1]] = 0;
    let queue: [YX, number][] = [[start, 0]];
    while (queue.length > 0) {
        // Pop the first element
        let [p, d] = queue.shift()!;

        const candidates: YX[] = [
            [p[0] - 1, p[1]],
            [p[0] + 1, p[1]],
            [p[0], p[1] - 1],
            [p[0], p[1] + 1]
        ];

        for (const new_p of candidates) {
            if (is_wall(map, p)) {
                continue;
            }

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

    const d_shortest_without_cheat = d_from_end[start[0]][start[1]];
    const d_min_saved = 100;
    const d_max_cheat_length = 20;

    let unique_points: YX[] = [];

    for (let y0 = 0; y0 < d_from_start.length; y0++) {
        for (let x0 = 0; x0 < d_from_start[y0].length; x0++) {
            let p: YX = [y0, x0];
            if (is_wall(map, p)) {
                continue;
            }
            unique_points.push(p);
        }
    }

    let unique_cheats = new Set<String>();

    for (let p0 of unique_points) {
        for (let p1 of unique_points) {
            let d_cheat = Math.abs(p0[0] - p1[0]) + Math.abs(p0[1] - p1[1]);
            if (d_cheat > d_max_cheat_length) {
                continue;
            }

            // Distance start -> p0 -> p1 (+d_cheat) -> end
            let d_with_cheat = d_from_start[p0[0]][p0[1]] + d_cheat + d_from_end[p1[0]][p1[1]];
            let d_saved = d_shortest_without_cheat - d_with_cheat;
            if (d_saved >= d_min_saved) {
                unique_cheats.add(`${p0[0]}_${p0[1]}_${p1[0]}_${p1[1]}`);
            }
        }
    }

    console.log(`The answer is: ${unique_cheats.size}`);
}

main();
