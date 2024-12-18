struct Cpu {
    a: u64, // Registers
    b: u64,
    c: u64,
    pc: usize, // Program counter
}

fn fetch_combo_operand(cpu: &Cpu, operand: u8) -> u64 {
    match operand {
        0 | 1 | 2 | 3 => operand as u64,
        4 => cpu.a,
        5 => cpu.b,
        6 => cpu.c,
        _ => panic!("Invalid operand"),
    }
}

fn adv(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.a = cpu.a >> operand;
}

fn bxl(cpu: &mut Cpu, operand: u8) {
    cpu.b = cpu.b ^ (operand as u64);
}

fn bst(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.b = operand % 8;
}

fn jnz(cpu: &mut Cpu, operand: u8) {
    if cpu.a != 0 {
        cpu.pc = operand as usize;
    }
}

fn bxc(cpu: &mut Cpu) {
    cpu.b = cpu.b ^ cpu.c;
}

fn out(cpu: &mut Cpu, co: u8) -> u8 {
    let operand = fetch_combo_operand(cpu, co);
    (operand % 8) as u8
}

fn bdv(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.b = cpu.a >> operand;
}

fn cdv(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.c = cpu.a >> operand;
}

fn run_and_check(cpu: &mut Cpu, program: &Vec<u8>, expected: &Vec<u8>) -> bool {
    let mut i = 0;
    while cpu.pc < program.len() {
        let opcode = program[cpu.pc];
        cpu.pc += 1;
        let operand = program[cpu.pc];
        cpu.pc += 1;

        match opcode {
            0 => adv(cpu, operand),
            1 => bxl(cpu, operand),
            2 => bst(cpu, operand),
            3 => jnz(cpu, operand),
            4 => bxc(cpu),
            5 => {
                if out(cpu, operand) != expected[i] {
                    return false;
                }
                i += 1;
                if i >= expected.len() {
                    return true;
                }
            }
            6 => bdv(cpu, operand),
            7 => cdv(cpu, operand),
            _ => panic!("Invalid opcode"),
        }
    }

    false
}

fn find_candidates_for_lower_12_bits(
    program: &Vec<u8>,
    desired_1: u8,
    desired_2: u8,
    desired_3: u8,
    desired_4: u8,
) -> Vec<u16> {
    let mut result = vec![];
    for a in 0..(1 << 19) - 1 {
        let a12 = (a & 0b111111111111) as u16;
        if result.contains(&a12) {
            continue;
        }

        let mut cpu = Cpu {
            a,
            b: 0,
            c: 0,
            pc: 0,
        };

        if !run_and_check(
            &mut cpu,
            program,
            &vec![desired_1, desired_2, desired_3, desired_4],
        ) {
            continue;
        }
        result.push(a12);
    }
    result
}

fn main() {
    let mut program = vec![];

    // Read each line from stdin
    std::io::stdin().lines().for_each(|line| {
        let line = line.unwrap();
        if line.starts_with("Program: ") {
            program = line
                .split_whitespace()
                .last()
                .unwrap()
                .split(",")
                .map(|x| x.parse::<u8>().unwrap())
                .collect();
        }
    });

    let mut candidates = vec![];
    for i in (0..program.len()).step_by(4) {
        let d0 = program[i + 0];
        let d1 = program[i + 1];
        let d2 = program[i + 2];
        let d3 = program[i + 3];
        candidates.push(find_candidates_for_lower_12_bits(&program, d0, d1, d2, d3));
    }

    let mut solutions = vec![];
    for a in candidates[0].iter() {
        for b in candidates[1].iter() {
            for c in candidates[2].iter() {
                for d in candidates[3].iter() {
                    let reg_a = ((*d as u64) << 36)
                        | ((*c as u64) << 24)
                        | ((*b as u64) << 12)
                        | (*a as u64);
                    if run_and_check(
                        &mut Cpu {
                            a: reg_a,
                            b: 0,
                            c: 0,
                            pc: 0,
                        },
                        &program,
                        &program,
                    ) {
                        solutions.push(reg_a);
                    }
                }
            }
        }
    }
    let solution = solutions.iter().min().unwrap();
    println!("The answer is: {}", solution);
}
