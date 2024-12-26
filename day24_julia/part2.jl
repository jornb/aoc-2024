parsed_initial = false
outputs = Dict()

while !eof(stdin)
    line = readline(stdin)

    if line == ""
        global parsed_initial = true
    elseif parsed_initial
        tokens = split(line, " ")

        # If tokens 1 and 3 are not in order, swap them to ensure everything is ordered
        if tokens[1] > tokens[3]
            tokens[1], tokens[3] = tokens[3], tokens[1]
        end

        outputs[tokens[5]] = (tokens[1], tokens[2], tokens[3])
    end
end

# Select all values with name starting with z
z_values = sort(collect(filter(x -> startswith(x, "z"), keys(outputs))))
num_bits = length(z_values)

# All x and y inputs should be XORed together
known_ab_xors = Dict()
missing_carries = []
for i in 1:num_bits
    x_name = i < 10 ? "x0$i" : "x$i"
    y_name = i < 10 ? "y0$i" : "y$i"
    # Find the first output which is an XOR between x_name and y_name
    K = collect(keys(outputs))
    it = findfirst(k -> outputs[k][1] == x_name && outputs[k][2] == "XOR" && outputs[k][3] == y_name, K)
    if it != nothing
        known_ab_xors[i] = K[it]
    end
end

swaps = []

for (i, ab_xor) in known_ab_xors
    K = collect(keys(outputs))
    it = findfirst(k -> outputs[k][2] == "XOR" && (outputs[k][1] == ab_xor || outputs[k][3] == ab_xor), K)
    z_name = i < 10 ? "z0$i" : "z$i"
    if it != nothing
        k = K[it]
        if k != z_name
            println("Wrong Z: $k should be $z_name")
            push!(swaps, (k, z_name))
        end
    else
        lhs, op, rhs = outputs[z_name]
        ab_xor_name = known_ab_xors[i]
        println("Wrong Z: $z_name = $lhs $op $rhs | should include $ab_xor_name")
        push!(swaps, (rhs, ab_xor_name))
    end
end

# Print solution
swapped_wires = []
for (a, b) in swaps
    push!(swapped_wires, a)
    push!(swapped_wires, b)
end
swapped_wires = sort(swapped_wires)
println("The answer is: " * join(swapped_wires, ","))
