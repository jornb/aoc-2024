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

fn main() {
    mut sum := u64(0);
    for line in os.get_lines() {
        mut secret := line.u64();
        for _ in 0..2000 {
            secret = evolve(secret);
        }
        sum += secret;
        println("$line: $secret");
    }
    println("The answer is: $sum");
}