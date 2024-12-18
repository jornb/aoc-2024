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

fn out(cpu: &mut Cpu, co: u8, output: &mut Vec<u8>) {
    let operand = fetch_combo_operand(cpu, co);
    let x = (operand % 8) as u8;
    output.push(x);
}

fn bdv(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.b = cpu.a >> operand;
}

fn cdv(cpu: &mut Cpu, co: u8) {
    let operand = fetch_combo_operand(cpu, co);
    cpu.c = cpu.a >> operand;
}

fn run(cpu: &mut Cpu, program: &Vec<u8>, output: &mut Vec<u8>) {
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
            5 => out(cpu, operand, output),
            6 => bdv(cpu, operand),
            7 => cdv(cpu, operand),
            _ => panic!("Invalid opcode"),
        }
    }
}

fn main() {
    let mut a = 0;
    let mut b = 0;
    let mut c = 0;
    let mut program = vec![];

    // Read each line from stdin
    std::io::stdin().lines().for_each(|line| {
        let line = line.unwrap();

        if line.starts_with("Register A: ") {
            a = line
                .split_whitespace()
                .last()
                .unwrap()
                .parse::<u64>()
                .unwrap();
        } else if line.starts_with("Register B: ") {
            b = line
                .split_whitespace()
                .last()
                .unwrap()
                .parse::<u64>()
                .unwrap();
        } else if line.starts_with("Register C: ") {
            c = line
                .split_whitespace()
                .last()
                .unwrap()
                .parse::<u64>()
                .unwrap();
        } else if line.starts_with("Program: ") {
            program = line
                .split_whitespace()
                .last()
                .unwrap()
                .split(",")
                .map(|x| x.parse::<u8>().unwrap())
                .collect();
        }
    });

    let mut output: Vec<u8> = vec![];
    let mut cpu = Cpu { a, b, c, pc: 0 };

    run(&mut cpu, &program, &mut output);

    println!(
        "The answer is: {}",
        output
            .iter()
            .map(|x| x.to_string())
            .collect::<Vec<String>>()
            .join(",")
    );
}
