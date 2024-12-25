import os

fn mix(secret u64, n u64) u64 {
    return secret ^ n
}

fn prune(secret u64) u64 {
    return secret % 16777216
}

fn evolve(old_secret u64) u64 {
    mut secret := prune(mix(old_secret, old_secret * 64));
    secret = prune(mix(secret, secret / 32));
    secret = prune(mix(secret, secret * 2048));
    return secret
}

fn to_key(d1 int, d2 int, d3 int, d4 int) string {
    return '$d1,$d2,$d3,$d4'
}

fn calculate_scores(deltas []int, prices []int) map[string]int {
    mut keys := map[string]int{}
    for i in 3..2000 {
        key := to_key(deltas[i-3], deltas[i-2], deltas[i-1], deltas[i]);
        if !(key in keys) {
            keys[key] = prices[i];
        }
    }
    return keys
}

fn main() {
    println("Calculating prices and deltas");
    mut scores := []map[string]int{}
    for line in os.get_lines() {
        mut p := []int{};
        mut d := []int{};
        mut secret := line.u64();
        mut p1 := int(secret % 10);
        mut p2 := 0;
        for _ in 0..2000 {
            secret = evolve(secret);

            p2 = int(secret % 10);
            p << p2;
            d << p2 - p1;
            p1 = p2;
        }

        scores << calculate_scores(d, p);
    }

    println("Calculating optimal deltas");
    mut answer := i64(0);
    mut best_deltas := [0, 0, 0, 0];
    for d1 in -9..10 {
        println("d1: $d1");
        C.fflush(C.stdout);
        for d2 in -9..10 {
            for d3 in -9..10 {
                for d4 in -9..10 {
                    key := to_key(d1, d2, d3, d4);
                    mut score := 0;
                    for s in scores {
                        if key in s {
                            score += s[key];
                        }
                    }
                    if score > answer {
                        best_deltas = [d1, d2, d3, d4];
                        answer = score;
                    }
                }
            }
        }
    }
    println("Optimal deltas: $best_deltas");
    println("The answer is: $answer");
}
